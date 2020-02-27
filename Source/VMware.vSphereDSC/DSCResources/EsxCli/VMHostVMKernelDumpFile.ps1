+<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostVMKernelDumpFile : EsxCliBaseDSC {
    VMHostVMKernelDumpFile() {
        $this.EsxCliCommand = 'system.coredump.file'
    }

    <#
    .DESCRIPTION

    Specifies the name of the Datastore for the dump file.
    #>
    [DscProperty(Key)]
    [string] $DatastoreName

    <#
    .DESCRIPTION

    Specifies the file name of the dump file.
    #>
    [DscProperty(Key)]
    [string] $FileName

    <#
    .DESCRIPTION

    Specifies whether the VMKernel dump Vmfs file should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the size in MB of the dump file. If not provided, a default size for the current machine is calculated.
    #>
    [DscProperty()]
    [nullable[long]] $Size

    <#
    .DESCRIPTION

    Specifies whether to deactivate and unconfigure the dump file being removed. This option is required if the file is active.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $CouldNotRetrieveFileSystemsInformationMessage = "Could not retrieve information about File Systems on VMHost {0}. For more information: {1}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            if ($this.Ensure -eq [Ensure]::Present) {
                $addVMKernelDumpFileMethodArguments = @{
                    datastore = $this.DatastoreName
                    file = $this.FileName
                }

                $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName, $addVMKernelDumpFileMethodArguments)
            }
            else {
                $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
                $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)
                $removeVMKernelDumpFileMethodArguments = @{
                    file = $vmKernelDumpFile.Path
                }

                $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName, $removeVMKernelDumpFileMethodArguments)
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
            $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = ($vmKernelDumpFile.Count -ne 0)
            }
            else {
                $result = ($vmKernelDumpFile.Count -eq 0)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelDumpFile] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelDumpFile]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Translates the Datastore name from a volume UUID to volume name, if required.
    #>
    [string] TranslateDatastoreName($datastoreName) {
        $foundDatastoreName = $null
        $fileSystemsList = $null

        try {
            $fileSystemsList = Invoke-EsxCliCommandMethod -EsxCli $this.EsxCli -EsxCliCommandMethod 'storage.filesystem.list.Invoke({0})' -EsxCliCommandMethodArguments @{}
        }
        catch {
            throw ($this.CouldNotRetrieveFileSystemsInformationMessage -f $this.Name, $_.Exception.Message)
        }

        foreach ($fileSystem in $fileSystemsList) {
            if ($fileSystem.UUID -eq $datastoreName) {
                $foundDatastoreName = $fileSystem.VolumeName
                break
            }

            if ($fileSystem.VolumeName -eq $datastoreName) {
                $foundDatastoreName = $fileSystem.VolumeName
                break
            }
        }

        return $foundDatastoreName
    }

    <#
    .DESCRIPTION

    Retrieves the name of the specified dump file.
    #>
    [string] GetDumpFileName($dumpFile) {
        $fileParts = $dumpFile -Split '\.'
        return $fileParts[0]
    }

    <#
    .DESCRIPTION

    Converts the passed bytes value to MB value.
    #>
    [double] ConvertBytesValueToMBValue($bytesValue) {
        return [Math]::Round($bytesValue / 1MB)
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel dump file if it exists.
    #>
    [PSObject] GetVMKernelDumpFile($esxCliListMethodResult) {
        $foundDumpFile = @{}
        $result = @()

        foreach ($dumpFile in $esxCliListMethodResult) {
            $dumpFileParts = $dumpFile.Path -Split '/'
            $dumpFileDatastoreName = $this.TranslateDatastoreName($dumpFileParts[3])
            $dumpFileName = $this.GetDumpFileName($dumpFileParts[5])

            $result += ($this.DatastoreName -eq $dumpFileDatastoreName)
            $result += ($this.FileName -eq $dumpFileName)

            if ($null -ne $this.Size) {
                $result += ($this.Size -eq $this.ConvertBytesValueToMBValue($dumpFile.Size))
            }

            if ($result -NotContains $false) {
                $foundDumpFile.Path = $dumpFile.Path
                $foundDumpFile.Datastore = $dumpFileDatastoreName
                $foundDumpFile.File = $dumpFileName
                $foundDumpFile.Size = $this.ConvertBytesValueToMBValue($dumpFile.Size)

                break
            }

            $result = @()
        }

        return $foundDumpFile
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)

        if ($vmKernelDumpFile.Count -ne 0) {
            $result.DatastoreName = $vmKernelDumpFile.Datastore
            $result.FileName = $vmKernelDumpFile.File
            $result.Size = $vmKernelDumpFile.Size
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.DatastoreName = $this.DatastoreName
            $result.FileName = $this.FileName
            $result.Size = $this.Size
            $result.Ensure = [Ensure]::Absent
        }
    }
}
