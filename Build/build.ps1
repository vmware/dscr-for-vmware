<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
  .SYNOPSIS
  Updates the Code Coverage badge with the new percent from the unit tests.

  .PARAMETER CodeCoveragePercent
  The new value in percents from the Code Coverage of the unit tests. Default value is 0.

  .PARAMETER TextFilePath
  The path to the file containing the Code Coverage badge.
#>
function Update-CodeCoveragePercentInTextFile {
    [CmdletBinding()]
    param(
        [int] $CodeCoveragePercent = 0,
        [string] $TextFilePath
    )

    $badgeColor = switch ($CodeCoveragePercent) {
        {$_ -in 90..100} { 'brightgreen' }
        {$_ -in 75..89}  { 'yellow' }
        {$_ -in 60..74}  { 'orange' }
        default          { 'red' }
    }

    $readMeContent = Get-Content $TextFilePath
    $readMeContent = $readMeContent -replace "!\[Coverage\].+\)", "![Coverage](https://img.shields.io/badge/coverage-$CodeCoveragePercent%25-$badgeColor.svg?maxAge=60)"
    $readMeContent | Set-Content -Path $TextFilePath
}

$script:ProjectRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName

# Adds the Source directory from the repository to the list of modules directories.
$script:SourceRoot = Join-Path -Path $script:ProjectRoot -ChildPath 'Source'
$env:PSModulePath = $env:PSModulePath + ":$script:SourceRoot"

# Updating the content of the psm1 and psd1 files via the build module file.
$script:ModuleName = 'VMware.vSphereDSC'
$script:ModuleRoot = Join-Path -Path $script:SourceRoot -ChildPath $script:ModuleName
$script:BuildModuleFilePath = Join-Path -Path $script:ModuleRoot -ChildPath "$script:ModuleName.build.ps1"
. $script:BuildModuleFilePath

# Registeres default PSRepository.
Register-PSRepository -Default -ErrorAction SilentlyContinue

# Installs Pester.
Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck

# Runs all unit tests in the module.
$script:ModuleFolderPath = (Get-Module $script:ModuleName -ListAvailable).ModuleBase
$script:UnitTestsFolderPath = Join-Path (Join-Path $script:ModuleFolderPath 'Tests') 'Unit'
$script:ModuleUnitTestsResult = Invoke-Pester -Path "$script:UnitTestsFolderPath\*.Tests.ps1" `
              -CodeCoverage @{ Path = "$script:ModuleFolderPath\$script:ModuleName.psm1" } `
              -PassThru `
              -EnableExit

# Gets the coverage percent from the unit tests that were ran.
$script:NumberOfCommandsAnalyzed = $script:ModuleUnitTestsResult.CodeCoverage.NumberOfCommandsAnalyzed
$script:NumberOfCommandsMissed = $script:ModuleUnitTestsResult.CodeCoverage.NumberOfCommandsMissed

$script:CoveragePercent = [math]::Floor(100 - (($script:NumberOfCommandsMissed / $script:NumberOfCommandsAnalyzed) * 100))
$script:ReadMePath = Join-Path -Path $script:ProjectRoot -ChildPath 'README.md'

Update-CodeCoveragePercentInTextFile -CodeCoveragePercent $script:CoveragePercent -TextFilePath $script:ReadMePath
