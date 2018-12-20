<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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

$script:PsmPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psm1"
$script:PsdPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psd1"

$script:LicensePath = Join-Path -Path $script:ProjectRoot -ChildPath "LICENSE.txt"
# This is used to skip the lines from LICENSE.txt containing the repository name and the empty line after it.
$script:LicenseSkipLines = 2
$script:LicenseFileContent = Get-Content -Path $script:LicensePath | Select-Object -Skip $script:LicenseSkipLines

$script:ImportFolders = @('Enums', 'Classes', 'DSCResources')
$script:DSCResourcesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "DSCResources"

# Add License to psm1 file.
"<#" | Out-File -FilePath $script:PsmPath -Encoding Default
$script:LicenseFileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
"#>" + [System.Environment]::NewLine | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Add helper module to psm1 file.
"Using module '.\VMware.vSphereDSC.Helper.psm1'" | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Updating VMware.vSphereDSC.psm1 content with enums, classes and DSC Resources.
foreach ($folder in $script:ImportFolders) {
    $currentFolder = Join-Path -Path $script:ModuleRoot -ChildPath $folder

    if (Test-Path -Path $currentFolder) {
        $files = Get-ChildItem -Path $currentFolder -File -Filter '*.ps1'

        foreach ($file in $files) {
            $index = 1
            $startLine = 0
            $endLine = 0

            $fileContent = Get-Content -Path $file.FullName
            $fileContent | ForEach-Object {
                if ($_ -Like '*Copyright*') {
                    $startLine = $index
                }

                if ($_.Trim().EndsWith('#>') -and $startLine -ne 0) {
                    $endLine = $index
                    $startLine = 0
                }

                $index++
            }

            # We skip the comment lines for the License and the License text for each file.
            $fileContent = $fileContent[$endLine..($fileContent.Length - 1)]
            $fileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
        }
    }
}

# Updating VMware.vSphereDSC.psd1 content with DSC Resources to export.
if (Test-Path -Path $script:DSCResourcesFolder) {
    $resources = (Get-ChildItem -Path $script:DSCResourcesFolder | Select-Object -ExpandProperty BaseName) -join "', '"
    $resources = "'{0}'" -f $resources
    $dscResourcesToExport = "DscResourcesToExport = @($resources)"

    $index = 1
    $startLine = 0
    $endLine = 0
    $counter = 0

    $psdFileContent = Get-Content -Path $script:PsdPath
    $psdFileContent | ForEach-Object {
        if ($_ -Like '*DscResourcesToExport*') {
            $startLine = $index
            $counter++
        }

        if ($_.Trim().EndsWith(')') -and $counter -ne 0) {
            $endLine = $index
            $counter = 0
        }

        $index++
    }

    $psdFileContent = $psdFileContent[0..($startLine - 2)], $dscResourcesToExport, $psdFileContent[$endLine..($psdFileContent.Length - 1)]
    $psdFileContent | Out-File -FilePath $script:PsdPath -Encoding Default
}