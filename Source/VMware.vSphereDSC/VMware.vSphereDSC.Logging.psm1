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

    if ($null -eq $Arguments) {
        Write-Verbose -Message $message
    }
    else {
        Write-Verbose -Message ([string]::Format($Message, $Arguments))
    }
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

    if ($null -eq $Arguments) {
        Write-Warning -Message $message
    }
    else {
        Write-Warning -Message ([string]::Format($Message, $Arguments))
    }
}
