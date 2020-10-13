# contains all scriptPath that will be put into the module
$scriptPaths = @(
    (Join-Path $PSScriptRoot 'Classes')
    (Join-Path $PSScriptRoot 'Functions')
)

# inserts all scripts into the module
Get-ChildItem -Filter '*.ps1' -Path $scriptPaths -Recurse | ForEach-Object {
    . $_.FullName
}

# exported members are specified in the maifest
