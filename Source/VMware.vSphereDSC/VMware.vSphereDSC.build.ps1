$script:ModuleRoot = $PSScriptRoot
$script:ProjectRoot = (Get-Item -Path $script:ModuleRoot).Parent.Parent.FullName
$script:ModuleName = Split-Path -Path $script:ModuleRoot -Leaf

$script:PsmPath = Join-Path -Path $script:ModuleRoot -ChildPath "\$($script:ModuleName).psm1"
$script:PsdPath = Join-Path -Path $script:ModuleRoot -ChildPath "\$($script:ModuleName).psd1"

$script:LicensePath = Join-Path -Path $script:ProjectRoot -ChildPath "\LICENSE.txt"
# This is used to skip the lines from LICENSE.txt containing the repository name and the empty line after it.
$script:LicenseSkipLines = 2
$script:CommentLines = 2
$script:LicenseFileContent = Get-Content -Path $script:LicensePath | Select-Object -Skip $script:LicenseSkipLines

$script:ImportFolders = @('Enums', 'Classes', 'DSCResources')
$script:DSCResourcesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "\DSCResources"

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
            # We skip the comment lines for the License and the License text for each file.
            $fileContent = Get-Content -Path $file.FullName | Select-Object -Skip ($script:LicenseFileContent.Length + $script:CommentLines)
            $fileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
        }
    }
}

# Updating VMware.vSphereDSC.psd1 content with DSC Resources to export.
if (Test-Path -Path $script:DSCResourcesFolder) {
    $resources = (Get-ChildItem -Path $script:DSCResourcesFolder | Select-Object -ExpandProperty BaseName) -join "', '"
    $resources = "'{0}'" -f $resources
    $dscResourcesToExport = "DscResourcesToExport = @($resources)"

    $psdFileContent = (Get-Content -Path $script:PsdPath) -replace "DscResourcesToExport=@()*", $dscResourcesToExport
    $psdFileContent | Out-File -FilePath $script:PsdPath -Encoding Default
}