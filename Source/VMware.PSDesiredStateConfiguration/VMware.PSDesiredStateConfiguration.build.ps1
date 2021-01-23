<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:ModuleRoot = $PSScriptRoot
$script:ProjectRoot = (Get-Item -Path $script:ModuleRoot).Parent.Parent.FullName
$script:ModuleName = Split-Path -Path $script:ModuleRoot -Leaf

$script:PsdPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psd1"

$script:LicensePath = Join-Path -Path $script:ProjectRoot -ChildPath "LICENSE.txt"

# This is used to skip the lines from LICENSE.txt containing the repository name and the empty line after it.
$script:LicenseSkipLines = 2
$script:LicenseFileContent = Get-Content -Path $script:LicensePath | Select-Object -Skip $script:LicenseSkipLines

$script:ClassesPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Classes'
$script:FunctionsPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Functions'
$script:TestsPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Tests'
$script:ModuleFilePaths = @($script:ClassesPath, $script:FunctionsPath, $script:TestsPath)

<#
.Description
Checks if file contains the required license
#>
function EnsureLicenseInFile {
    param (
        [System.IO.FileInfo]
        $File,

        [string[]]
        $LicenseContent
    )

    $fileContent = Get-Content -Path $File.FullName
    $lineCounter = 1
    $startsWithLicenseContent = $true

    foreach ($licenseLine in $LicenseContent) {
        if ($fileContent[$lineCounter] -ne $licenseLine) {
            $startsWithLicenseContent = $false
            break
        }

        $lineCounter += 1
    }

    if (!$startsWithLicenseContent) {
        $modifiedFileContent = @()

        $modifiedFileContent += '<#'
        $LicenseContent | ForEach-Object -Process { $modifiedFileContent += $_ }
        $modifiedFileContent += '#>'
        $modifiedFileContent += [string]::Empty

        $fileContent | ForEach-Object -Process { $modifiedFileContent += $_ }

        $modifiedFileContent | Out-File -FilePath $File.FullName -Encoding Default
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

Get-ChildItem -Path $script:ModuleFilePaths -File -Recurse | ForEach-Object {
    EnsureLicenseInFile -File $_ -LicenseContent $script:LicenseFileContent
}

Update-ModuleVersion -FilePath $script:PsdPath
