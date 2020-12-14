<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.SYNOPSIS
Writes the specified message to the verbose message stream.

.DESCRIPTION
Writes the specified message to the verbose message stream. If arguments
are passed to the function, the message is formatted accordingly using [string]::Format method.

.PARAMETER Message
Specifies the message to write to the verbose message stream.

.PARAMETER Arguments
Specifies the arguments that are needed for formatting the message using [string]::Format method.
The message is expected to be a format string that expects the given arguments.
#>
function Write-VerboseLog {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Message,

        [Parameter()]
        [array] $Arguments
    )

    if ($null -ne $Arguments) {
        $Message = [string]::Format($Message, $Arguments)
    }
    
    Write-Verbose -Message $Message
}

<#
.SYNOPSIS
Writes the specified warning message to the PowerShell host.

.DESCRIPTION
Writes the specified warning message to the PowerShell host. The response to the warning depends on the value
of the user's $WarningPreference variable and the use of the WarningAction common parameter. If arguments
are passed to the function, the message is formatted accordingly using [string]::Format method.

.PARAMETER Message
Specifies the warning message to write to the PowerShell host.

.PARAMETER Arguments
Specifies the arguments that are needed for formatting the message using [string]::Format method.
The message is expected to be a format string that expects the given arguments.
#>
function Write-WarningLog {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Message,

        [Parameter()]
        [array] $Arguments
    )

    if ($null -ne $Arguments) {
        $Message = [string]::Format($Message, $Arguments)
    }
    
    Write-Warning -Message $Message
}

<#
.SYNOPSIS
Saves the messages to a log file.

.DESCRIPTION
Saves the messages to a log file, because Invoke-DscResource runs this in a separate runspace
where the streams are not accessable.

.PARAMETER Message
Specifies the message to write to the file.

.PARAMETER LogType
Type of the stream: Verbose, Warning etc..

.PARAMETER Connection
Connection to the vCenter server.

.PARAMETER ResourceName
Name of the DSC Resource.

.PARAMETER Arguments
Specifies the arguments that are needed for formatting the message using [string]::Format method.
The message is expected to be a format string that expects the given arguments.
#>
function Write-LogToFile {
    Param(
        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        [Parameter(Mandatory = $true)]
        [string]
        $LogType,

        [Parameter(Mandatory = $true)]
        [string]
        $Connection,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter()]
        [array] $Arguments

    )

    # do nothing in case no temp folder is available
    if ($null -eq $env:TEMP) {
        return
    }

    if ($null -ne $Arguments) {
        $Message = [string]::Format($Message, $Arguments)
    }

    # create file in the following format
    $logFilePath = Join-Path -Path $env:TEMP -ChildPath "__VMware.vSphereDSC_$($Connection)_$($ResourceName)_$($LogType).TMP"

    if (-not (Test-Path -Path $logFilePath -PathType 'Leaf')) {
        $file = New-Item -Path $logFilePath -ItemType 'File' -Force -ErrorAction 'SilentlyContinue'

        # exit function if file is not created
        if ($null -eq $file) {
            return
        }
    }
    
    $content = Get-Content -Path $logFilePath -Raw

    $content += $Message

    Set-Content -Path $logFilePath -Value $content -Force -ErrorAction 'SilentlyContinue'
}
