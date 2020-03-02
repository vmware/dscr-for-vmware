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
Retrieves the Module Version from the passed psd1 file.

.DESCRIPTION
Gets the content of the passed psd1 file.
Using a regex pattern retrieves the Module Version from the content of the psd1 file.
Returns the Module Version.

.PARAMETER PsdPath
Specifies the path to the psd1 file where the Module Version is located.
#>
function Get-ModuleVersion {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $PsdPath
    )

    $psdFileContent = Get-Content -Path $PsdPath

    $moduleVersionPattern = "(?<=ModuleVersion = ')(\d*.\d*.\d*.\d*)"
    $moduleVersionMatch = $psdFileContent | Select-String -Pattern $moduleVersionPattern

    return $moduleVersionMatch.Matches[0].Value
}

<#
.SYNOPSIS
Retrieves the description of the merged Pull Request via the GitHub API.

.DESCRIPTION
Constructs a query using the current commit 'sha' to retrieve the Pull Request information
via the GitHub API using the 'Auth Token' and returns the description of the found pull request.
The 'Auth Token' and current commit 'sha' are available through Travis CI environment variables.
#>
function Get-PullRequestDescription {
    [CmdletBinding()]
    [OutputType([string])]

    $repository = 'vmware/dscr-for-vmware'
    $searchType = 'pr'
    $pullRequestState = 'closed'

    $base64Token = [System.Convert]::ToBase64String([char[]] $env:GH_TOKEN)
    $uri = "https://api.github.com/search/issues?q=repo:$repository+type:$searchType+state:$pullRequestState+$env:TRAVIS_COMMIT is:merged"
    $method = 'Get'
    $headers = @{
        Authorization = "Basic $base64Token"
    }

    try {
        $pullRequestsInfo = Invoke-RestMethod -Uri $uri -Method $method -Headers $headers
    }
    catch {
        throw "An error occurred while retrieving the Pull Request information: $($_.Exception.Message)"
    }

    $pullRequest = $pullRequestsInfo.items[0]
    if ($null -eq $pullRequest) {
        <#
        Here the build was triggered without a Pull Request so the description should be
        retrieved from the commit body.
        #>
        $commitUri = "https://api.github.com/repos/$repository/commits/$env:TRAVIS_COMMIT"
        try {
            $commitInfo = Invoke-RestMethod -Uri $commitUri -Method $method -Headers $headers
        }
        catch {
            throw "An error occurred while retrieving the Commit information: $($_.Exception.Message)"
        }

        return $commitInfo.commit.message
    }

    return $pullRequest.body
}

<#
.SYNOPSIS
Updates the Changelog document with the changes mentioned in the Pull Request description.

.DESCRIPTION
Updates the content of the Changelog document adding a new section containing
the new module version and the changes made with the Pull Request which are mentioned in the description.

.PARAMETER ChangelogDocumentPath
Specifies the path to the Changelog document which is going to be updated.

.PARAMETER PullRequestDescription
Specifies the description of the changes made in the Pull Request.

.PARAMETER ModuleVersion
Specifies the new Module Version that is going to be added to the new section in the document.
#>
function Update-ChangelogDocument {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $ChangelogDocumentPath,

        [Parameter(Mandatory = $true)]
        [string] $PullRequestDescription,

        [Parameter(Mandatory = $true)]
        [string] $ModuleVersion
    )

    $changelogDocument = Get-Content -Path $ChangelogDocumentPath

    # To find the first section in CHANGELOG.md we need to find the first occurence of a date in the document which is part of the section.
    $datePattern = "\d{4}-\d{2}-\d{2}"
    $firstDateInFile = $changelogDocument | Select-String -Pattern $datePattern | Select-Object -First 1

    <#
    To find the Header length in CHANGELOG.md we need to substract two fron the found date line number because the header end is on the
    previous line and also because LineNumber starts from 1 and the array indices start from 0.
    #>
    $headerLength = $firstDateInFile.LineNumber - 2

    $changelogHeader = $changelogDocument[0..$headerLength]
    $changelogSections = $changelogDocument[($headerLength + 1)..$changelogDocument.Length]

    $currentDate = Get-Date -Format yyyy-MM-dd
    $newSectionHeader = "## $ModuleVersion - $currentDate"

    $changelogDocumentNewContent = $changelogHeader + $newSectionHeader + $PullRequestDescription + $changelogSections
    $changelogDocumentNewContent | Set-Content -Path $ChangelogDocumentPath
}

<#
.SYNOPSIS
Updates the Code Coverage badge with the new percent from the unit tests.

.DESCRIPTION
Updates the content of the passed text file by modifying the Code Coverage badge
with the specified percent from the unit tests.

.PARAMETER CodeCoveragePercent
The new value in percents from the Code Coverage of the unit tests. Default value is 0.

.PARAMETER TextFilePath
The path to the file containing the Code Coverage badge.
#>
function Update-CodeCoveragePercentInTextFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false)]
        [int] $CodeCoveragePercent = 0,

        [Parameter(Mandatory = $true)]
        [string] $TextFilePath
    )

    if ($CodeCoveragePercent -lt 90) {
        throw "The Code Coverage is $CodeCoveragePercent which is below 90 percent."
    }

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

<#
.SYNOPSIS
Comments the 'RequiredModules' lines in the specified module manifest file.

.DESCRIPTION
Comments the 'RequiredModules' lines in the specified module manifest file. The 'RequiredModules' lines need to be
commented, because the build executes the Unit tests without PowerCLI being installed on the machine. So VMware.PowerCLI is not needed
as a dependency to execute the Unit tests and it is commented out in the manifest file to avoid throwing an exception and failing the build.

.PARAMETER ModuleManifestPath
Specifies the path to the module manifest file where the 'RequiredModules' lines are located.
#>
function Disable-RequiredModulesInModuleManifest {
    [CmdletBinding()]
    [OutputType([void])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleManifestPath
    )

    $startLinePattern = '*RequiredModules*'
    $endLinePattern = ')'
    $requiredModulesToComment = @()

    $index = 1
    $startLine = 0
    $endLine = 0

    $moduleManifestContent = Get-Content -Path $ModuleManifestPath -ErrorAction Stop -Verbose:$false
    foreach ($line in $moduleManifestContent) {
        if ($line -Like $startLinePattern) {
            $startLine = $index
        }

        # The 'RequiredModules' is an array which can be on multiple lines, so each line till the end of the array needs to be commented.
        if ($startLine -ne 0) { $requiredModulesToComment += '# ' + $line }

        if ($line.Trim().EndsWith($endLinePattern) -and $startLine -ne 0) {
            $endLine = $index
            break
        }

        $index++
    }

    $moduleManifestContent = $moduleManifestContent[0..($startLine - 2)], $requiredModulesToComment, $moduleManifestContent[$endLine..($moduleManifestContent.Length - 1)]
    $moduleManifestContent | Out-File -FilePath $ModuleManifestPath -Encoding Default
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

# Comments the 'RequiredModules' array in the module manifest file.
$moduleManifestPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psd1"
Disable-RequiredModulesInModuleManifest -ModuleManifestPath $moduleManifestPath

# Runs all unit tests in the module.
$script:ModuleFolderPath = (Get-Module $script:ModuleName -ListAvailable).ModuleBase
$script:UnitTestsFolderPath = Join-Path (Join-Path $script:ModuleFolderPath 'Tests') 'Unit'
$script:ModuleUnitTestsResult = Invoke-Pester -Path "$script:UnitTestsFolderPath\*" `
              -CodeCoverage @{ Path = "$script:ModuleFolderPath\$script:ModuleName.psm1" } `
              -PassThru `
              -EnableExit

# Gets the coverage percent from the unit tests that were ran.
$script:NumberOfCommandsAnalyzed = $script:ModuleUnitTestsResult.CodeCoverage.NumberOfCommandsAnalyzed
$script:NumberOfCommandsMissed = $script:ModuleUnitTestsResult.CodeCoverage.NumberOfCommandsMissed

$script:CoveragePercent = [math]::Floor(100 - (($script:NumberOfCommandsMissed / $script:NumberOfCommandsAnalyzed) * 100))
$script:ReadMePath = Join-Path -Path $script:ProjectRoot -ChildPath 'README.md'

Update-CodeCoveragePercentInTextFile -CodeCoveragePercent $script:CoveragePercent -TextFilePath $script:ReadMePath

if ($env:TRAVIS_EVENT_TYPE -eq 'push' -and $env:TRAVIS_BRANCH -eq 'master') {
    $psdPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psd1"
    $changelogDocumentPath = Join-Path -Path $script:ProjectRoot -ChildPath 'CHANGELOG.md'

    $moduleVersion = Get-ModuleVersion -PsdPath $psdPath
    $pullRequestDescription = Get-PullRequestDescription

    Update-ChangelogDocument -ChangelogDocumentPath $changelogDocumentPath -PullRequestDescription $pullRequestDescription -ModuleVersion $moduleVersion
}
