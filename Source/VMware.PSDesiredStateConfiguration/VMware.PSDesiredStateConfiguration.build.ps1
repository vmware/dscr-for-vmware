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

    $moduleVersionPattern = "(?<=ModuleVersion = ')(\d*.\d*.\d*.\d*)"
    $moduleVersionMatch = $FileContent | Select-String -Pattern $moduleVersionPattern
    [System.Version] $currentVersion = $moduleVersionMatch.Matches[0].Value

    $newVersion = (New-Object -TypeName 'System.Version' $currentVersion.Major, $currentVersion.Minor, $currentVersion.Build, ($currentVersion.Revision + 1)).ToString()

    $fileContent = Get-Content $filePath -Raw

    ($fileContent -replace $moduleVersionPattern, $newVersion) | Out-File $FilePath
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

# add required dsc resource path to the modules path for the unit tests
$moduleRoot = $PSScriptRoot

$configPath = Join-Path (Join-Path (Join-Path $moduleRoot 'Tests') 'Required Dsc Resources') 'MyDscResource'

$env:PSModulePath += ":$configPath"

# update version in psd1

$psd1Path = Join-Path $PSScriptRoot 'VMware.PSDesiredStateConfiguration.psd1'

Update-ModuleVersion $psd1Path
