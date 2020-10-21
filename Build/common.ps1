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
.Synopsis
Runs the unit tests for the specified module and returns code coverage percentage.

.Description
Runs the unit tests for the specified module and returns code coverage percentage. The tests should be located in a Tests\Unit location in the modules directory.
The code coverage result of the tests gets updated in the README.md document.

.Notes
The code coverage logic leads to the unit tests running slower.
Bug link: https://github.com/pester/Pester/issues/1318

.Parameter ModuleName
Name of the module whose unit tests should be run

.Parameter DisableCodeCoverage
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

$script:ProjectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName

# Adds the Source directory from the repository to the list of modules directories.
$script:SourceRoot = Join-Path -Path $script:ProjectRoot -ChildPath 'Source'
$script:ReadMePath = Join-Path -Path $script:ProjectRoot -ChildPath 'README.md'
$Script:ChangelogDocumentPath = Join-Path -Path $Script:ProjectRoot -ChildPath 'CHANGELOG.md'

$env:PSModulePath += "$([System.IO.Path]::PathSeparator)$script:SourceRoot"

# Registeres default PSRepository.
Register-PSRepository -Default -ErrorAction SilentlyContinue

# Installs Pester.
Install-Module -Name Pester -RequiredVersion 4.10.1 -Scope CurrentUser -Force -SkipPublisherCheck
