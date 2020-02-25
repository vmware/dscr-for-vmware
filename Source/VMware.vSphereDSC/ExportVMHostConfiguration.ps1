<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    $Credential,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputPath
)

$script:viServer = $null
$script:vmHost = $null
$script:vmHostConfigurationName = "VMHost_Config"
$script:vmHostConfigurationFileName = $script:vmHostConfigurationName + '_' + (Get-Date -Format 'yyyy-MM-dd') + '.ps1'
$script:vmHostDscConfigContent = New-Object -TypeName 'System.Text.StringBuilder'

<#
.DESCRIPTION

Imports the required modules that are needed for extracting the DSC Configuration of the specified VMHost.
#>
function Import-RequiredModules {
    <#
        The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
        when importing the 'VMware.VimAutomation.Core' Module.
    #>
    $savedVerbosePreference = $global:VerbosePreference
    $global:VerbosePreference = 'SilentlyContinue'

    Import-Module -Name VMware.VimAutomation.Core

    $global:VerbosePreference = $savedVerbosePreference
}

<#
.DESCRIPTION

Connects to the specified vSphere Server with the passed Credentials.
#>
function Connect-VSphereServer {
    try {
        Write-Host "Connecting to vSphere Server $Server..." -BackgroundColor DarkGreen -ForegroundColor White
        Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false
    }
    catch {
        throw "Cannot establish connection to vSphere Server $Server. For more information: $($_.Exception.Message)"
    }
}

<#
.DESCRIPTION

Retrieves the VMHost with the specified name from the specified vSphere Server.
#>
function Get-VSphereVMHost {
    try {
        Write-Host "Retrieving VMHost $VMHostName from vSphere Server $($script:viServer.Name)..." -BackgroundColor DarkGreen -ForegroundColor White
        Get-VMHost -Server $script:viServer -Name $VMHostName -ErrorAction Stop -Verbose:$false
    }
    catch {
        throw "Could not retrieve VMHost $VMHostName from vSphere Server $($script:viServer.Name). For more information: $($_.Exception.Message)"
    }
}

<#
.DESCRIPTION

Closes the last open connection to the specified vSphere Server.
#>
function Disconnect-VSphereServer {
    try {
        Write-Host "Closing connection to vSphere Server $($script:viServer.Name)..." -BackgroundColor DarkGreen -ForegroundColor White
        Disconnect-VIServer -Server $script:viServer -Confirm:$false -ErrorAction Stop -Verbose:$false
    }
    catch {
        throw "Cannot close connection to vSphere Server $($script:viServer.Name). For more information: $($_.Exception.Message)"
    }
}

<#
.DESCRIPTION

Sets the parameters for the VMHost DSC Configuration - Server, Credential and VMHostNames.
#>
function Set-ConfigurationParameters {
    [void] $script:vmHostDscConfigContent.Append("Param(`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [Parameter(Mandatory = `$true)]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [ValidateNotNullOrEmpty()]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [string]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    `$Server,`r`n`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [Parameter(Mandatory = `$true)]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [ValidateNotNull()]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [System.Management.Automation.PSCredential]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    `$Credential,`r`n`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [Parameter(Mandatory = `$true)]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [ValidateNotNullOrEmpty()]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    [string[]]`r`n")
    [void] $script:vmHostDscConfigContent.Append("    `$VMHostNames`r`n")
    [void] $script:vmHostDscConfigContent.Append(")`r`n`r`n")
}

<#
.DESCRIPTION

Sets the DSC Configuration Data for the VMHost DSC Configuration.
#>
function Set-ConfigurationData {
    [void] $script:vmHostDscConfigContent.Append("`$script:configurationData = @{`r`n")
    [void] $script:vmHostDscConfigContent.Append("    AllNodes = @(`r`n")
    [void] $script:vmHostDscConfigContent.Append("        @{`r`n")
    [void] $script:vmHostDscConfigContent.Append("            NodeName = 'localhost'`r`n")
    [void] $script:vmHostDscConfigContent.Append("            PSDscAllowPlainTextPassword = `$true`r`n")
    [void] $script:vmHostDscConfigContent.Append("            Server = `$Server`r`n")
    [void] $script:vmHostDscConfigContent.Append("            Credential = `$Credential`r`n")
    [void] $script:vmHostDscConfigContent.Append("            VMHostNames = `$VMHostNames`r`n")
    [void] $script:vmHostDscConfigContent.Append("        }`r`n")
    [void] $script:vmHostDscConfigContent.Append("    )`r`n")
    [void] $script:vmHostDscConfigContent.Append("}`r`n`r`n")
}

<#
.DESCRIPTION

The main function for extracting the VMHost DSC Configuration. It acts as a call dispatcher, calling all required functions
in the proper order to get the full Configuration.
#>
function Export-VMHostConfiguration {
    Import-RequiredModules
    $script:viServer = Connect-VSphereServer
    $script:vmHost = Get-VSphereVMHost

    Set-ConfigurationParameters
    Set-ConfigurationData

    [void] $script:vmHostDscConfigContent.Append("Configuration $script:vmHostConfigurationName {`r`n")
    [void] $script:vmHostDscConfigContent.Append("    Import-DscResource -ModuleName VMware.vSphereDSC`r`n`r`n")
    [void] $script:vmHostDscConfigContent.Append("    Node `$AllNodes.NodeName {`r`n")
    [void] $script:vmHostDscConfigContent.Append("        foreach (`$vmHostName in `$AllNodes.VMHostNames) {`r`n")

    [void] $script:vmHostDscConfigContent.Append("        }`r`n")

    [void] $script:vmHostDscConfigContent.Append("    }`r`n")
    [void] $script:vmHostDscConfigContent.Append("}`r`n`r`n")

    [void] $script:vmHostDscConfigContent.Append("$script:vmHostConfigurationName -ConfigurationData `$script:configurationData")

    $outputFile = $OutputPath + $script:vmHostConfigurationFileName
    $script:vmHostDscConfigContent.ToString() | Out-File -FilePath $outputFile -Encoding Default

    Disconnect-VSphereServer
}

Export-VMHostConfiguration
