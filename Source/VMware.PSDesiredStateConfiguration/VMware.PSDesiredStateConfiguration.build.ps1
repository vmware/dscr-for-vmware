<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.Description
Checks if file contains the required license
#>
function EnsureLicenseInFile {
    param (
        [System.IO.FileInfo]
        $File,

        [string]
        $License,

        [switch]
        $AddLicense
    )

    $fileContent = Get-Content $File.FullName -Raw

    if (-not $fileContent.StartsWith($license)) {
        if ($AddLicense) {
            #add license to start of file
            $fileContent = $License + [System.Environment]::NewLine + [System.Environment]::NewLine + $fileContent
            $fileContent | Out-File $file.FullName -Encoding Default
        } else {
            # throw if license is not found
            throw "$($file.FullName) does not contain the required license"
        }    
    }
}

<#
.Description
Updates the version of the module
#>
function Update-ModuleVersion {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [string] $FilePath
    )

    $fileContent = Get-Content $filePath -Raw
    $moduleVersionPattern = "(?<=ModuleVersion = ')(\d*.\d*.\d*.\d*)"
    $moduleVersionMatch = $FileContent | Select-String -Pattern $moduleVersionPattern

    [System.Version] $currentVersion = $moduleVersionMatch.Matches[0].Value

    $newVersion = (New-Object -TypeName 'System.Version' $currentVersion.Major, $currentVersion.Minor, $currentVersion.Build, ($currentVersion.Revision + 1)).ToString()

    # -NoNewline switch prevents a new line being added every time
    ($fileContent -replace $moduleVersionPattern, $newVersion) | Out-File $FilePath -NoNewline
}

# paths to all scripts
$scriptPaths = @(
    (Join-Path $PSScriptRoot 'Classes')
    (Join-Path $PSScriptRoot 'Functions')
    (Join-Path $PSScriptRoot 'Tests')
)

# license with comment brackets
$licensePath = (Join-Path (Split-Path (Split-Path $PSScriptRoot)) 'LICENSE.txt')
$license = Get-Content $licensePath -Raw
$license = $license.Trim()
$license = "<`#" + [System.Environment]::NewLine + $license + [System.Environment]::NewLine + "`#>"

Get-ChildItem -Filter '*.ps1' -Path $scriptPaths -Recurse | ForEach-Object {
    # check if all files have their license
    EnsureLicenseInFile $_ $license
}

# update version in psd1

$psd1Path = Join-Path $PSScriptRoot 'VMware.PSDesiredStateConfiguration.psd1'

Update-ModuleVersion $psd1Path
