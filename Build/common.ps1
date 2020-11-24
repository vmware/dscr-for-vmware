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
.DESCRIPTION
BuildFlags defines operations which the build should perform.
Update_PSDSC flag runs the build process for VMware.PSDesiredStateConfiguration.
Update_VSDSC flag runs the build process for VMware.vSphereDSC.
Tests_VSDSC flag runs the VMware.vSphereDSC unit tests.
Tests_PSDSC flag runs the VMware.PSDesiredStateConfiguration unit tests.
None is the defaut value for not running any additional steps.
#>
[Flags()] enum BuildFlags {
    Update_PSDSC = 1
    Update_VSDSC = 2
    Tests_VSDSC = 4
    Tests_PSDSC = 8
    None = 16
}

<#
.SYNOPSIS
Checks if a certain DesiredFlag is included in the InputFlag.
.DESCRIPTION
Checks if a certain DesiredFlag is included in the InputFlag.
The check is performed using a binary and on flags.
.PARAMETER InputFlag
Contains all the flags for the current build.
.PARAMETER DesiredFlag
The flag that gets checked if it's contained the current build flags.
#>
function Test-Flag {
    [OutputType([bool])]
    Param (
        [BuildFlags]
        $InputFlag,

        [BuildFlags]
        $DesiredFlag
    )

    ($InputFlag -band $DesiredFlag) -ne 0
}

<#
.SYNOPSIS
Finds and returns a list of file paths that have been changed since last build
.DESCRIPTION
Finds and returns a list of file paths that have been changed since last build.
The changes are searched in the .git HEAD from the current commit to the last travis commit or DSCAutomation commit.
#>
function Get-ChangedFiles {
    [OutputType([System.String[]])]
    Param()

    $lastTravisCommit = 1

    # stops at first found travis commit or DSCAutomation commit
    while ($true) {
        $commitInfo = git show HEAD~$lastTravisCommit
        $author = $commitInfo[1]

        if ($author.Contains('travis@travis-ci.org') -or $author.Contains('DSCAutomation')) {
            break
        }

        $lastTravisCommit += 1
    }

    # extract names of changed files from HEAD history
    $changedFiles = git diff --name-only HEAD..HEAD~$lastTravisCommit

    $changedFiles
}

<#
.SYNOPSIS
Depending on the changes made in the project [BuildFlags] get set and returned.
.DESCRIPTION
Depending on the changes made in the project [BuildFlags] get set and returned.
The returned value contains all steps that should be perfomred depending on build change.
If there is change in the any of the modules in Source then the changed module build + unit tests get run.
If there is change in the build process or in .travis.yml the unit tests for all modules get run.
#>
function Set-BuildFlags {
    # retrieve a list of changed files
    $changedFiles = Get-ChangedFiles

    $flagResult = 0

    foreach ($changedFile in $changedFiles) {
        if ($changedFile.Contains('Source')) {
            # module change triggers the it's build and tests to run
            if ($changedFile.Contains('VMware.PSDesiredStateConfiguration')) {
                $flagResult = $flagResult -bor [BuildFlags]::Update_PSDSC
                $flagResult = $flagResult -bor [BuildFlags]::Tests_PSDSC
            } elseif ($changedFile.Contains('VMware.vSphereDSC')) {
                $flagResult = $flagResult -bor [BuildFlags]::Update_VSDSC
                $flagResult = $flagResult -bor [BuildFlags]::Tests_VSDSC
            }
        } elseif ($changedFile.Contains('Build') -or $changedFiles.Contains('.travis.yml')) {
            # build change triggers unit tests to be run
            $flagResult = $flagResult -bor [BuildFlags]::Tests_PSDSC
            $flagResult = $flagResult -bor [BuildFlags]::Tests_VSDSC
        }
    }

    # no major changes have been made
    if ($flagResult -eq 0) {
        $flagResult = [BuildFlags]::None
    }

    $flagResult
}

<#
.SYNOPSIS
Runs the unit tests for the specified module and returns code coverage percentage.

.DESCRIPTION
Runs the unit tests for the specified module and returns code coverage percentage. 
The tests should be located in a Tests\Unit location in the modules directory.
The code coverage result of the tests gets updated in the README.md document.
This function relies on Pester for running the unit tests. If the module is not found it gets installed.

.NOTES
The code coverage logic leads to the unit tests running slower.
Bug link: https://github.com/pester/Pester/issues/1318

.PARAMETER ModuleName
Name of the module whose unit tests should be run

.PARAMETER DisableCodeCoverage
Disables code coverage for the unit tests.
With this flag turned on the function does not return a result.
#>
function Invoke-UnitTests {
    [CmdletBinding()]
    [OutputType([int])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName,

        [switch]
        $DisableCodeCoverage
    )

    if ($null -eq (Get-Module -Name 'Pester' -ListAvailable)) {
        # Install Pester.
        Write-Host 'Installing Pester'

        # suppress progress messages during installation due
        # to broken display on Travis console
        $oldProgressPreference = $ProgressPreference
        $Global:ProgressPreference = 'SilentlyContinue'

        Install-Module -Name Pester -RequiredVersion 4.10.1 -Scope CurrentUser -Force -SkipPublisherCheck

        $Global:ProgressPreference = $oldProgressPreference

        Write-Host 'Pester Installed'   
    }

    # Runs all unit tests in the module.
    $moduleFolderPath = (Get-Module $ModuleName -ListAvailable).ModuleBase
    $unitTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Unit'

    $invokePesterSplatParams = @{
        Path = "$unitTestsFolderPath\*"
        PassThru = $true
        EnableExit = $true
    }

    if($DisableCodeCoverage) {
        Invoke-Pester @invokePesterSplatParams
    } else {
        $invokePesterSplatParams['CodeCoverage'] = @{ Path = "$ModuleFolderPath\$ModuleName.psm1" }

        $moduleUnitTestsResult = Invoke-Pester @invokePesterSplatParams

        $numberOfCommandsAnalyzed = $moduleUnitTestsResult.CodeCoverage.NumberOfCommandsAnalyzed
        $numberOfCommandsMissed = $moduleUnitTestsResult.CodeCoverage.NumberOfCommandsMissed

        # Gets the coverage percent from the unit tests that were ran.
        $coveragePercent = [math]::Floor(100 - (($numberOfCommandsMissed / $numberOfCommandsAnalyzed) * 100))

        return $coveragePercent
    }
}

# Define script variables
$script:ProjectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName
$script:SourceRoot = Join-Path -Path $script:ProjectRoot -ChildPath 'Source'
$script:ReadMePath = Join-Path -Path $script:ProjectRoot -ChildPath 'README.md'
$Script:ChangelogDocumentPath = Join-Path -Path $Script:ProjectRoot -ChildPath 'CHANGELOG.md'

# Adds the Source directory from the repository to the list of modules directories.
$env:PSModulePath += "$([System.IO.Path]::PathSeparator)$script:SourceRoot"

# Registeres default PSRepository.
Register-PSRepository -Default -ErrorAction SilentlyContinue
