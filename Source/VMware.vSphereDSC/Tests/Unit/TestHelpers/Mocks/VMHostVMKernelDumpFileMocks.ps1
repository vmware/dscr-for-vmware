<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVMKernelDumpFileProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostVMKernelDumpFileProperties
}

function New-MocksInSetForVMHostVMKernelDumpFile {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $vmHostVMKernelDumpFileProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostVMKernelDumpFileProperties.FileName = $script:constants.DumpFileName
    $vmHostVMKernelDumpFileProperties.Ensure = 'Present'

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $esxCliMock = $script:esxCli
    $esxCliSetMethodArgsMock = $script:constants.EsxCliSetMethodArgs

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliSetMethodArgsMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-EsxCliCommandMethod -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVMKernelDumpFileProperties
}

function New-MocksForVMHostVMKernelDumpFile {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $esxCliMock = $script:esxCli
    $esxCliListMethodMock = $script:vmKernelDumpFile
    $esxCliFileSystemsListMock = $script:fileSystem

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliListMethodMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-EsxCliCommandMethod -MockWith { return $esxCliFileSystemsListMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVMKernelDumpFileProperties
}

function New-MocksWhenTheVMHostVMKernelDumpFileDoesNotExistAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $vmHostVMKernelDumpFileProperties.DatastoreName = $script:constants.DatastoreName + $script:constants.DatastoreName
    $vmHostVMKernelDumpFileProperties.FileName = $script:constants.DumpFileName + $script:constants.DumpFileName
    $vmHostVMKernelDumpFileProperties.Ensure = 'Present'
    $vmHostVMKernelDumpFileProperties.Size = $script:constants.DumpFileSizeInMB + $script:constants.DumpFileSizeInMB

    $vmHostVMKernelDumpFileProperties
}

function New-MocksWhenTheVMHostVMKernelDumpFileExistsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $vmHostVMKernelDumpFileProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostVMKernelDumpFileProperties.FileName = $script:constants.DumpFileName
    $vmHostVMKernelDumpFileProperties.Ensure = 'Present'
    $vmHostVMKernelDumpFileProperties.Size = $script:constants.DumpFileSizeInMB

    $vmHostVMKernelDumpFileProperties
}

function New-MocksWhenTheVMHostVMKernelDumpFileDoesNotExistAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $vmHostVMKernelDumpFileProperties.DatastoreName = $script:constants.DatastoreName + $script:constants.DatastoreName
    $vmHostVMKernelDumpFileProperties.FileName = $script:constants.DumpFileName + $script:constants.DumpFileName
    $vmHostVMKernelDumpFileProperties.Ensure = 'Absent'
    $vmHostVMKernelDumpFileProperties.Size = $script:constants.DumpFileSizeInMB + $script:constants.DumpFileSizeInMB

    $vmHostVMKernelDumpFileProperties
}

function New-MocksWhenTheVMHostVMKernelDumpFileExistsAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVMKernelDumpFileProperties = New-VMHostVMKernelDumpFileProperties

    $vmHostVMKernelDumpFileProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostVMKernelDumpFileProperties.FileName = $script:constants.DumpFileName
    $vmHostVMKernelDumpFileProperties.Ensure = 'Absent'
    $vmHostVMKernelDumpFileProperties.Size = $script:constants.DumpFileSizeInMB

    $vmHostVMKernelDumpFileProperties
}
