<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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

$script:EnumsFolder = Join-Path -Path $script:ModuleRoot -ChildPath "Enums"
$script:ClassesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "Classes"
$script:ClassesFiles = Get-ChildItem -Path $script:ClassesFolder -File -Filter *.ps1 -Recurse
$script:DSCResourcesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "DSCResources"

class Node {
    [string] $Name

    [string] $BaseName

    [string] $FileName

    [Node[]] $Edge

    [void] AddEdge($edge) {
        if ($null -eq $this.Edge) {
            $this.Edge = @()
        }

        $this.Edge += $edge
    }
}

function Add-DependenciesBetweenClasses {
    [CmdletBinding()]
    param (
        [System.Object[]] $Files
    )

    $allClasses = @()

    foreach ($file in $Files) {
        $fileContent = Get-Content -Path $file.FullName
        $errors = $null

        $tokens = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref] $errors)
        $classTokens = $tokens | Where-Object { $_.Content -eq 'class' }

        foreach ($classToken in $classTokens) {
            $classLine = $fileContent[$classToken.StartLine - 1]
            $classLine = $classLine.Substring('class '.Length)
            $classLineBaseInheritor = $classLine.Split(':').Split('{') | ForEach-Object { $_.Trim() }
            $baseName = $null
            $name = $null

            # If the class does not have a base class that inherits from, the array will contain only two values: <class name> and <empty string>
            if ($classLineBaseInheritor.Length -gt 2) {
                $name = $classLineBaseInheritor[0]
                $baseName = $classLineBaseInheritor[1]
            }
            else {
                $name = $classLineBaseInheritor[0]
            }

            $currentClass = [Node]::new()
            $currentClass.Name = $name
            $currentClass.BaseName = $baseName
            $currentClass.FileName = $file.Name

            $allClasses += $currentClass
        }
    }

    foreach ($class in $allClasses) {
        if (![string]::IsNullOrEmpty($class.BaseName)) {
            $baseClass = $allClasses | Where-Object { $_.Name -eq $class.BaseName }
            $class.AddEdge($baseClass)
        }
    }

    return $allClasses
}

function Get-OrderedClasses {
    [CmdletBinding()]
    param (
        [Node] $Class,
        [ref] $ResolvedClasses
    )

    foreach ($edge in $Class.Edge) {
        $containedEdge = $ResolvedClasses.Value | Where-Object { $_.Name -eq $edge.Name }
        if ($null -eq $containedEdge) {
            Get-OrderedClasses -Class $edge -ResolvedClasses ([ref] $ResolvedClasses.Value)
        }
    }

    $containedClass = $ResolvedClasses.Value | Where-Object { $_.Name -eq $Class.Name }
    if ($null -eq $containedClass) {
        $ResolvedClasses.Value.Add($Class)
    }
}

function Get-OrderedFiles {
    [CmdletBinding()]
    param (
        [System.Object[]] $Files
    )

    $classes = Add-DependenciesBetweenClasses -Files $Files
    $resolvedClasses = New-Object System.Collections.Generic.List[Node]

    foreach ($class in $classes) {
        Get-OrderedClasses -Class $class -ResolvedClasses ([ref] $resolvedClasses)
    }

    $orderedFiles = @()

    foreach ($class in $resolvedClasses) {
        $containedFile = $orderedFiles | Where-Object { $_.Name -eq $class.FileName }
        if ($null -eq $containedFile) {
            $file = $Files | Where-Object { $_.Name -eq $class.FileName }
            $orderedFiles += $file
        }
    }

    return $orderedFiles
}

function Get-LinesRange {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [System.Object[]] $FileContent,
        [string] $StartLinePattern,
        [string] $EndLinePattern
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

    return $range
}

function Update-ContentOfModuleFile {
    [CmdletBinding()]
    param(
        [string] $Folder,
        [System.Object[]] $Files
    )

    if (Test-Path -Path $Folder) {
        if ($null -eq $Files) {
            $Files = Get-ChildItem -Path $Folder -File -Filter *.ps1 -Recurse
        }

        foreach ($file in $Files) {
            $fileContent = Get-Content -Path $file.FullName

            $range = Get-LinesRange -FileContent $fileContent -StartLinePattern '*Copyright*' -EndLinePattern '#>'
            $endLine = $range.EndLine

            # We skip the comment lines for the License and the License text for each file.
            $fileContent = $fileContent[$endLine..($fileContent.Length - 1)]
            $fileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
        }
    }
}

function Update-ModuleVersion {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [System.Object[]] $FileContent
    )

    $moduleVersionPattern = "(?<=ModuleVersion = ')(\d*.\d*.\d*.\d*)"
    $moduleVersionMatch = $FileContent | Select-String -Pattern $moduleVersionPattern
    [System.Version] $currentVersion = $moduleVersionMatch.Matches[0].Value

    $newVersion = (New-Object -TypeName 'System.Version' $currentVersion.Major, $currentVersion.Minor, $currentVersion.Build, ($currentVersion.Revision + 1)).ToString()

    return $FileContent -Replace $moduleVersionPattern, $newVersion
}

# Add License to psm1 file.
"<#" | Out-File -FilePath $script:PsmPath -Encoding Default
$script:LicenseFileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
"#>" + [System.Environment]::NewLine | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Add helper module to psm1 file.
"Using module '.\VMware.vSphereDSC.Helper.psm1'" | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Add logging module to psm1 file.
"Using module '.\VMware.vSphereDSC.Logging.psm1'" | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Updating VMware.vSphereDSC.psm1 content with enums.
Update-ContentOfModuleFile -Folder $script:EnumsFolder

<#
Updating VMware.vSphereDSC.psm1 content with classes.
The files need to be ordered by the inheritance of the classes inside and not alphabetically.
Because we can have cases where the child class is defined before the parent class which will result in an exception.
Example:
class DatastoreInventory : Inventory {
}

class Inventory {
}

So with this function we first order the classes based on the inheritance(the first classes in the array are the ones that do not inherit from anything and then
after them we order the classes that inherit from them and so on). And the last classes in the array are the ones that are not base classes to any other class.
After we order the classes, we order the files based on the classes defined inside. With this step we guarantee that when a class is placed in the psm1 file, if the file has a
class it inherits from, that class will be already defined and no exception will be thrown like the above example.

After ordering the files we pass them to the Update-ContentOfModuleFile function to place the content in the module file.
#>
$orderedClassesFiles = Get-OrderedFiles -Files $script:ClassesFiles
Update-ContentOfModuleFile -Folder $script:ClassesFolder -Files $orderedClassesFiles

# Updating VMware.vSphereDSC.psm1 content with DSC Resources.
Update-ContentOfModuleFile -Folder $script:DSCResourcesFolder

# Updating VMware.vSphereDSC.psd1 content with DSC Resources to export.
if (Test-Path -Path $script:DSCResourcesFolder) {
    $resources = (Get-ChildItem -Path $script:DSCResourcesFolder -File -Filter *.ps1 -Recurse | Select-Object -ExpandProperty BaseName) -join "', '"
    $resources = "'{0}'" -f $resources
    $dscResourcesToExport = "DscResourcesToExport = @($resources)"

    $psdFileContent = Get-Content -Path $script:PsdPath

    # Updating the module version in the psd1 file.
    $psdFileContent = Update-ModuleVersion -FileContent $psdFileContent

    $range = Get-LinesRange -FileContent $psdFileContent -StartLinePattern '*DscResourcesToExport*' -EndLinePattern ')'
    $startLine = $range.StartLine
    $endLine = $range.EndLine

    $psdFileContent = $psdFileContent[0..($startLine - 2)], $dscResourcesToExport, $psdFileContent[$endLine..($psdFileContent.Length - 1)]
    $psdFileContent | Out-File -FilePath $script:PsdPath -Encoding Default
}
