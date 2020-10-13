@{

ModuleToProcess = 'VMware.PSDesiredStateConfiguration.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '4f9a62bf-e2a6-4bd1-ac20-ccf127bc643e'

# Author of this module
Author = 'VMware'

# Company or vendor of this module
CompanyName = 'VMware'

# Copyright statement for this module
Copyright = '(c) VMware. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This PowerShell module contains logic for creating and running object based DSC Configurations'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @( '.\Classes\DscItems.ps1' )

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'New-VmwDscConfiguration',
    'Start-VmwDscConfiguration',
    'Get-VmwDscConfiguration',
    'Test-VmwDscConfiguration'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('VMware', 'Automation', 'DSC', 'DesiredStateConfiguration')

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/vmware/dscr-for-vmware'

    } # End of PSData hashtable
}

}
