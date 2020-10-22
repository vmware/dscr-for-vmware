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

        [Parameter(Mandatory = $false)]
        [string] $ModuleName,

        [Parameter(Mandatory = $false)]
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
    $newSectionHeader = [string]::Empty

    if ([string]::IsNullOrEmpty($ModuleName) -or [string]::IsNullOrEmpty($ModuleName)) {
        # generic header for project level changes
        $newSectionHeader = "## $currentDate"
    } else {
        # specific header for model changes
        $newSectionHeader = "## $ModuleName $ModuleVersion - $currentDate"
    }

    # assemble CHANGELOG.md content
    $changelogDocumentNewContent = $changelogHeader + $newSectionHeader + $PullRequestDescription + $changelogSections
    $changelogDocumentNewContent | Set-Content -Path $ChangelogDocumentPath
}

<#
.SYNOPSIS
Updates the Code Coverage badge with the new percent from the unit tests.

.DESCRIPTION
Updates the content of the passed text file by modifying the Code Coverage badge
with the specified percent from the unit tests.

.PARAMETER TextFilePath
The path to the file containing the Code Coverage badge.

.PARAMETER ModuleName
Name of the module whose Code Coverage badge gets updated.

.PARAMETER CodeCoveragePercent
The new value in percents from the Code Coverage of the unit tests. Default value is 0.
#>
function Update-CodeCoveragePercentInTextFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $TextFilePath,

        [Parameter(Mandatory = $true)]
        [string] $ModuleName,

        [Parameter(Mandatory = $false)]
        [int] $CodeCoveragePercent = 0
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
    $readMeContent = $readMeContent -replace "\*\*$ModuleName\*\* !\[Coverage\].+\)", "**$ModuleName** ![Coverage](https://img.shields.io/badge/coverage-$CodeCoveragePercent%25-$badgeColor.svg?maxAge=60)"
    $readMeContent | Set-Content -Path $TextFilePath
}

<#
.SYNOPSIS
Gets the range between the start and the end line of the specified line pattern.

.DESCRIPTION
Gets the range between the start and the end line of the specified line pattern.
The returned hashtable contains the start line and the end line of the specified line pattern.

.PARAMETER FileContent
The content of the file in which the line pattern is going to be searched.

.PARAMETER StartLinePattern
The start of the searched line pattern.

.PARAMETER EndLinePattern
The end of the searched line pattern.
#>
function Get-LinesRange {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $FileContent,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $StartLinePattern,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $EndLinePattern
    )

    $range = @{}

    $index = 1
    $startLine = 0
    $endLine = 0

    foreach ($line in $FileContent) {
        if ($line -Like $StartLinePattern) {
            $startLine = $index
        }

        if ($line.Trim().EndsWith($EndLinePattern) -and $startLine -ne 0) {
            $endLine = $index
            break
        }

        $index++
    }

    $range.StartLine = $startLine
    $range.EndLine = $endLine

    $range
}

<#
.SYNOPSIS
Gets the 'RequiredModules' array for the VMware.vSphereDSC module from the specified RequiredModules file.

.DESCRIPTION
Gets the 'RequiredModules' array for the VMware.vSphereDSC module from the specified RequiredModules file.
The RequiredModules file contains the array of 'RequiredModules' that the VMware.vSphereDSC module depends on.

.PARAMETER RequiredModulesContent
The content of the RequiredModules file which contains the array of 'RequiredModules' that the VMware.vSphereDSC module depends on.
#>
function Get-RequiredModules {
    [CmdletBinding()]
    [OutputType([string[]])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $RequiredModulesContent
    )

    $licenseRange = Get-LinesRange -FileContent $RequiredModulesContent -StartLinePattern '*Copyright*' -EndLinePattern '#>'
    $licenseEndLine = $licenseRange.EndLine + 1

    # We skip the comment lines for the License and the License text for the RequiredModules file.
    $requiredModules = $RequiredModulesContent[$licenseEndLine..($RequiredModulesContent.Length - 1)]
    $requiredModules
}

<#
.SYNOPSIS
Updates the 'RequiredModules' array in the specified module manifest file with the specified 'RequiredModules' array.

.DESCRIPTION
Updates the 'RequiredModules' array in the specified module manifest file with the specified RequiredModules array.
The 'RequiredModules' array contains the modules that the VMware.vSphereDSC module depends on.

.PARAMETER ModuleManifestContent
The content of the module manifest file which should be updated with the 'RequiredModules' array.

.PARAMETER RequiredModules
The array of required modules that the VMware.vSphereDSC module depends on.
#>
function Update-RequiredModules {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $ModuleManifestContent,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $RequiredModules
    )

    $requiredModulesInModuleManifestRange = Get-LinesRange -FileContent $ModuleManifestContent -StartLinePattern "*RequiredModules*" -EndLinePattern ")"
    $requiredModulesStartLine = $requiredModulesInModuleManifestRange.StartLine
    $requiredModulesEndLine = $requiredModulesInModuleManifestRange.EndLine

    $moduleManifestUpdatedContent = @()
    for ($i = 0; $i -le $requiredModulesStartLine - 2; $i++) {
        $moduleManifestUpdatedContent += $ModuleManifestContent[$i]
    }

    $moduleManifestUpdatedContent += $RequiredModules

    for ($i = $requiredModulesEndLine; $i -le $ModuleManifestContent.Length - 1; $i++) {
        $moduleManifestUpdatedContent += $ModuleManifestContent[$i]
    }

    $moduleManifestUpdatedContent
}

<#
.DESCRIPTION
Start the building process for the VMware.PSDesiredStateConfiguration module and
returns the updated module version
#>
function Start-PSDesiredStateConfigurationBuild {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    # run the specific module build file
    $moduleName = 'VMware.PSDesiredStateConfiguration'
    $moduleRoot = Join-Path -Path $script:SourceRoot -ChildPath $moduleName
    $buildModuleFilePath = Join-Path -Path $moduleRoot -ChildPath "$moduleName.build.ps1"
    . $buildModuleFilePath

    $psdPath = Join-Path -Path $moduleRoot -ChildPath "$($moduleName).psd1"

    # return module version
    Get-ModuleVersion -psdPath $psdPath
}

<#
.DESCRIPTION
Start the building process for the VMware.vSphereDsc module and
returns the updated module version
#>
function Start-vSphereDSCBuild {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    # Updating the content of the psm1 and psd1 files via the build module file.
    $moduleName = 'VMware.vSphereDSC'
    $moduleRoot = Join-Path $Script:SourceRoot $moduleName
    $buildModuleFilePath = Join-Path -Path $moduleRoot -ChildPath "$moduleName.build.ps1"
    . $buildModuleFilePath

    $psdPath = Join-Path -Path $moduleRoot -ChildPath "$($moduleName).psd1"
    $psdContent = Get-Content -Path $psdPath

    if ($env:TRAVIS_EVENT_TYPE -eq 'push' -and $env:TRAVIS_BRANCH -eq 'master') {
        # Retrieving the 'RequiredModules' array from the RequiredModules file.
        $requiredModulesFilePath = Join-Path -Path $ModuleRoot -ChildPath 'RequiredModules.ps1'
        $requiredModulesContent = Get-Content -Path $requiredModulesFilePath
        $requiredModules = Get-RequiredModules -RequiredModulesContent $requiredModulesContent
    
        # Updating the required modules array in the psd1 file.
        $psdContent = Update-RequiredModules -ModuleManifestContent $psdContent -RequiredModules $requiredModules
        $psdContent | Out-File -FilePath $psdPath -Encoding Default
    }

    # return module version
    Get-ModuleVersion -psdPath $psdPath
}

<#
.DESCRIPTION
Invokes the VMware.vSphereDSC unit tests and updates the code coverage percent
in the README.md file
#>
function Invoke-vSphereDSCTests {
    $moduleName = 'VMware.vSphereDSC'
    $moduleRoot = Join-Path -Path $script:SourceRoot -ChildPath $moduleName
    $psdPath = Join-Path -Path $moduleRoot -ChildPath "$($moduleName).psd1"
    $psdContent = Get-Content -Path $psdPath

    # The 'RequiredModules' array needs to be empty before the Unit tests are executed because 'VMware.PowerCLI' is not installed during the build procedure.
    $emptyRequiredModulesArray = @("RequiredModules = @()")
    $psdContent = Update-RequiredModules -ModuleManifestContent $psdContent -RequiredModules $emptyRequiredModulesArray
    $psdContent | Out-File -FilePath $psdPath -Encoding Default

    # run tests and calculate coverage percent
    $coveragePercent = Invoke-UnitTests $moduleName

    $updateCodeCoveragePercentInTextFileParams = @{
        CodeCoveragePercent = $coveragePercent
        TextFilePath = $Script:ReadMePath
        ModuleName = $moduleName
    }

    # update coverage in README.md
    Update-CodeCoveragePercentInTextFile @updateCodeCoveragePercentInTextFileParams
}

<#
.SYNOPSIS
Sets the result from the VMware.PSDesiredStateConfiugration unit tests into the README.md file.
.DESCRIPTION
Sets the result from the VMware.PSDesiredStateConfiugration unit tests
into the README.md file. The tests result gets retrieved from a Travis workspace file
that gets populated from a different Travis job.
#>
function Set-PSDesiredStateConfigurationTestsResults {
    $moduleName = 'PSDesiredStateConfiguration'

    # get code coverage result from shared travis workspace file
    $coveragePath = Join-Path $env:TRAVIS_BUILD_DIR $env:PSDS_CODECOVERAGE_RESULTFILE
    $coveragePercent = [int] (Get-Content $coveragePath -Raw)

    Remove-Item $env:TRAVIS_BUILD_DIR $env:PSDS_CODECOVERAGE_RESULTFILE

    $updateCodeCoveragePercentInTextFileParams = @{
        CodeCoveragePercent = $coveragePercent
        TextFilePath = $Script:ReadMePath
        ModuleName = $moduleName
    }

    Update-CodeCoveragePercentInTextFile @updateCodeCoveragePercentInTextFileParams
}

# add common functions, script variables and perform common logic
. (Join-Path $PSScriptRoot 'common.ps1')

# flags for which steps to be executed
$flagChanges = Set-BuildFlags

# will contain modules that are changed and their updated versions
$changedModuleNameToVersion = @{}

if (Test-Flag -InputFlag $flagChanges -DesiredFlag Update_PSDSC) {
    Write-Host '---------VMware.PSDesiredStateConfiguration build started'

    $version = Start-PSDesiredStateConfigurationBuild
    $changedModuleNameToVersion['VMware.PSDesiredStateConfiguration'] = $version

    Write-Host '---------VMware.PSDesiredStateConfiguration build ended'
}

if (Test-Flag -InputFlag $flagChanges -DesiredFlag Tests_PSDSC) {
    Write-Host '---------VMware.PSDesiredStateConfiguration tests started'

    Set-PSDesiredStateConfigurationTestsResults

    Write-Host '---------VMware.PSDesiredStateConfiguration tests ended'
}

if (Test-Flag -InputFlag $flagChanges -DesiredFlag Update_VSDSC) {
    Write-Host '---------VMware.vSphereDSC build started'

    $version = Start-vSphereDSCBuild
    $changedModuleNameToVersion['VMware.vSphereDSC'] = $version

    Write-Host '---------VMware.vSphereDSC build ended'
}

if (Test-Flag -InputFlag $flagChanges -DesiredFlag Tests_VSDSC) {
    Write-Host '---------VMware.vSphereDSC tests started'

    Invoke-vSphereDSCTests

    Write-Host '---------VMware.vSphereDSC tests ended'
}

if ($env:TRAVIS_EVENT_TYPE -eq 'push' -and $env:TRAVIS_BRANCH -eq 'master') {
    # get request description
    $pullRequestDescription = Get-PullRequestDescription

    # check if there is a change in the modules
    if ($changedModuleNameToVersion.Count -eq 0) {
        # when no change in the modules is found then
        # a generic entry with only a date gets generated in the CHANGELOG.md
        $updateChangeLogParams = @{
            ChangelogDocumentPath = $Script:ChangelogDocumentPath
            PullRequestDescription = $pullRequestDescription
        }

        Update-ChangelogDocument @updateChangeLogParams  
    } else {
        # generates an entry for each changed module in the CHANGELOG.md
        foreach ($changedModuleKey in $changedModuleNameToVersion.Keys) {
            $updateChangeLogParams = @{
                ChangelogDocumentPath = $Script:ChangelogDocumentPath
                PullRequestDescription = $pullRequestDescription
                ModuleName = $changedModuleKey
                ModuleVersion = $changedModuleNameToVersion[$changedModuleKey]
            }

            Update-ChangelogDocument @updateChangeLogParams  
        }
    }
}
