<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

@{

# Script module or binary module file associated with this manifest.
RootModule = 'VMware.vSphereDSC.psm1'

# Version number of this module.
ModuleVersion = '2.1.0.63'

# ID used to uniquely identify this module
GUID = '664b57b4-bd8d-4a56-9984-278f7fe10cf8'

# Author of this module
Author = 'VMware'

# Company or vendor of this module
CompanyName = 'VMware'

# Copyright statement for this module
Copyright = '(c) 2018-2020 VMware. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This PowerShell module contains DSC Resources for vSphere.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
@{ "ModuleName" = "VMware.VimAutomation.Vds"; "ModuleVersion" = "11.2.0.12483615" },
@{ "ModuleName" = "VMware.VimAutomation.Storage"; "ModuleVersion" = "11.5.0.14901686" }
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @()

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
DscResourcesToExport = @('Datacenter', 'DatacenterFolder', 'DatastoreCluster', 'Folder', 'NfsUser', 'PowerCLISettings', 'vCenterSettings', 'vCenterStatistics', 'vCenterVMHost', 'VDPortGroup', 'VDSwitch', 'VDSwitchVMHost', 'VMHostAccount', 'VMHostAdvancedSettings', 'VMHostAgentVM', 'VMHostAuthentication', 'VMHostCache', 'VMHostConfiguration', 'VMHostDnsSettings', 'VMHostFirewallRuleset', 'VMHostIScsiHba', 'VMHostIScsiHbaTarget', 'VMHostNtpSettings', 'VMHostPciPassthrough', 'VMHostPermission', 'VMHostPowerPolicy', 'VMHostRole', 'VMHostSatpClaimRule', 'VMHostScsiLun', 'VMHostScsiLunPath', 'VMHostService', 'VMHostSettings', 'VMHostSyslog', 'VMHostTpsSettings', 'NfsDatastore', 'VmfsDatastore', 'VMHostVssPortGroup', 'VMHostVssPortGroupSecurity', 'VMHostVssPortGroupShaping', 'VMHostVssPortGroupTeaming', 'VMHostAcceptanceLevel', 'VMHostDCUIKeyboard', 'VMHostNetworkCoreDump', 'VMHostSharedSwapSpace', 'VMHostSNMPAgent', 'VMHostSoftwareDevice', 'VMHostVMKernelActiveDumpFile', 'VMHostVMKernelActiveDumpPartition', 'VMHostVMKernelDumpFile', 'VMHostVMKernelModule', 'VMHostvSANNetworkConfiguration', 'VMHostVDSwitchMigration', 'VMHostVssMigration', 'VMHostPhysicalNic', 'VMHostVssNic', 'VMHostIPRoute', 'VMHostGraphics', 'VMHostGraphicsDevice', 'VMHostVss', 'VMHostVssBridge', 'VMHostVssSecurity', 'VMHostVssShaping', 'VMHostVssTeaming', 'DrsCluster', 'HACluster')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('VMware', 'Automation', 'PowerCLI', 'DSC', 'DesiredStateConfiguration')

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/vmware/dscr-for-vmware'

    } # End of PSData hashtable

}

}
