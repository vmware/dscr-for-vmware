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
    $OutputPath,

    [Parameter()]
    [string[]]
    $VMHostDscResourcesToExport
)

$script:viServer = $null
$script:vmHost = $null
$script:scsiLuns = $null
$script:iScsiHbas = $null

$script:availableVSphereDscResources = $null
$script:vSphereDscResourcesPropertiesToExclude = $null
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

Retrieves all SCSI devices that are available on the specified VMHost.
#>
function Get-ScsiDevices {
    if ($null -eq $script:scsiLuns) {
        try {
            $script:scsiLuns = Get-ScsiLun -Server $script:viServer -VmHost $script:vmHost -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw "Could not retrieve SCSI devices from VMHost $VMHostName on vSphere Server $($script:viServer.Name). For more information: $($_.Exception.Message)"
        }
    }
}

<#
.DESCRIPTION

Retrieves all iSCSI Host Bus Adapters that are available on the specified VMHost.
#>
function Get-IScsiHostBusAdapters {
    if ($null -eq $script:iScsiHbas) {
        try {
            $script:iScsiHbas = Get-VMHostHba -Server $script:viServer -VMHost $script:vmHost -Type 'iSCSI' -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw "Could not retrieve iSCSI Host Bus Adapters from VMHost $VMHostName on vSphere Server $($script:viServer.Name). For more information: $($_.Exception.Message)"
        }
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
Gets the list of the properties for the specified VMHost DSC Resource that are going to be populated in the VMHost DSC Configuration.
The common properties for all VMHost DSC Resources - Server and Credential as well as one of VMHostName and Name (depending on the base class of the DSC Resource) are not
part of the returned list of properties because they are populated automatically.

.PARAMETER VMHostDscResource
The VMHost DSC Resource which properties are going to be retrieved.
#>
function Get-VMHostDscResourceProperties {
    [CmdletBinding()]
    [OutputType([array])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]
        $VMHostDscResource
    )

    $vmHostDscResourcePropertiesToExclude = $script:vSphereDscResourcesPropertiesToExclude

    # VMHostRole DSC Resource does not have a property for VMHost.
    if ($VMHostDscResource.Name -ne 'VMHostRole') {
        if ($VMHostDscResource.Properties.Name -Contains 'VMHostName') {
            $vmHostDscResourcePropertiesToExclude += 'VMHostName'
            [void] $script:vmHostDscConfigContent.Append("                VMHostName = `$vmHostName`r`n")
        }
        elseif ($VMHostDscResource.Properties.Name -Contains 'Name') {
            $vmHostDscResourcePropertiesToExclude += 'Name'
            [void] $script:vmHostDscConfigContent.Append("                Name = `$vmHostName`r`n")
        }
    }

    $VMHostDscResource.Properties | Where-Object -FilterScript { $vmHostDscResourcePropertiesToExclude -NotContains $_.Name }
}

<#
.DESCRIPTION
Pushes the specified string property to the VMHost DSC Resource block with the following syntax: <propertyName> = '<propertyValue>'.

.PARAMETER PropertyName
The name of the string property that is going to be pushed to the VMHost DSC Resource block.

.PARAMETER PropertyValue
The value of the string property that is going to be pushed to the VMHost DSC Resource block.
#>
function Push-StringPropertyToVMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PropertyName,

        [Parameter()]
        [string]
        $PropertyValue
    )

    [void] $script:vmHostDscConfigContent.Append("                $propertyName = '$propertyValue'`r`n")
}

<#
.DESCRIPTION
Pushes the specified bool property to the VMHost DSC Resource block with the following syntax: <propertyName> = $<propertyValue>.
The property is pushed only when its value is not $null.

.PARAMETER PropertyName
The name of the bool property that is going to be pushed to the VMHost DSC Resource block.

.PARAMETER PropertyValue
The value of the bool property that is going to be pushed to the VMHost DSC Resource block.
#>
function Push-BoolPropertyToVMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PropertyName,

        [Parameter()]
        [nullable[bool]]
        $PropertyValue
    )

    if ($null -ne $PropertyValue) {
        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = `$$($PropertyValue.ToString().ToLower())`r`n")
    }
}

<#
.DESCRIPTION
Pushes the specified string array property to the VMHost DSC Resource block with the following syntax: <propertyName> = @('<arrayValue1>', '<arrayValue2>').
If the property is $null, empty array is pushed: @().

.PARAMETER PropertyName
The name of the string array property that is going to be pushed to the VMHost DSC Resource block.

.PARAMETER PropertyValue
The value of the string array property that is going to be pushed to the VMHost DSC Resource block.
#>
function Push-StringArrayPropertyToVMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PropertyName,

        [Parameter()]
        [string[]]
        $PropertyValue
    )

    if ($null -eq $PropertyValue) {
        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = @()`r`n")
    }
    else {
        $arrayProperty = '@('
        for ($i = 0; $i -lt $PropertyValue.Length; $i++) {
            if ($i -eq $PropertyValue.Length - 1) {
                $arrayProperty += "'$($PropertyValue[$i])'"
            }
            else {
                $arrayProperty += "'$($PropertyValue[$i])', "
            }
        }
        $arrayProperty += ')'

        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = $arrayProperty`r`n")
    }
}

<#
.DESCRIPTION
Pushes the specified value type property to the VMHost DSC Resource block with the following syntax: <propertyName> = <propertyValue>.
The property is pushed only when its value is not $null.

.PARAMETER PropertyName
The name of the value type property that is going to be pushed to the VMHost DSC Resource block.

.PARAMETER PropertyValue
The value of the value type property that is going to be pushed to the VMHost DSC Resource block.
#>
function Push-ValueTypePropertyToVMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PropertyName,

        [Parameter()]
        [System.ValueType]
        $PropertyValue
    )

    if ($null -ne $PropertyValue) {
        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = $PropertyValue`r`n")
    }
}

<#
.DESCRIPTION
Pushes the specified hashtable property to the VMHost DSC Resource block with the following syntax: <propertyName> = @{ <key1> = '<value1>', <key2> = '<value2>' }.
If the property is $null, empty hashtable is pushed: @{}.

.PARAMETER PropertyName
The name of the hashtable property that is going to be pushed to the VMHost DSC Resource block.

.PARAMETER PropertyValue
The value of the hashtable property that is going to be pushed to the VMHost DSC Resource block.
#>
function Push-HashtablePropertyToVMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PropertyName,

        [Parameter()]
        [hashtable]
        $PropertyValue
    )

    if ($null -eq $PropertyValue) {
        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = @{}`r`n")
    }
    else {
        $hashtableProperty = "@{`r`n"
        foreach ($key in $PropertyValue.Keys) {
            if ($null -eq $PropertyValue.$key) { $hashtableProperty += "                    '$key' = `$null`r`n" }
            else { $hashtableProperty += "                    '$key' = '$($PropertyValue.$key)'`r`n" }
        }
        $hashtableProperty += '                }'

        [void] $script:vmHostDscConfigContent.Append("                $PropertyName = $hashtableProperty`r`n")
    }
}

<#
.DESCRIPTION
Adds a new DSC Resource block in the VMHost DSC Configuration for the specified DSC Resource with the information retrieved from the Get() method of the DSC Resource.

.PARAMETER VMHostDscResourceName
The name of the DSC Resource that is going to be added to the VMHost DSC Configuration as a DSC Resource block.

.PARAMETER VMHostDscResourceInstanceName
The name of the instance of the DSC Resource with the specified name that is going to be added to the VMHost DSC Configuration as a DSC Resource block.

.PARAMETER VMHostDscGetMethodResult
The result of the Get() method of the specified DSC Resource that is going to be added to the VMHost DSC Configuration as a DSC Resource block.
#>
function New-VMHostDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostDscResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostDscResourceInstanceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]
        $VMHostDscGetMethodResult
    )

    [void] $script:vmHostDscConfigContent.Append("            $VMHostDscResourceName '$VMHostDscResourceInstanceName' {`r`n")
    [void] $script:vmHostDscConfigContent.Append("                Server = `$AllNodes.Server`r`n")
    [void] $script:vmHostDscConfigContent.Append("                Credential = `$AllNodes.Credential`r`n")

    $vmHostDscResource = $script:availableVSphereDscResources | Where-Object -FilterScript { $_.Name -eq $VMHostDscResourceName }
    $vmHostDscResourceProperties = Get-VMHostDscResourceProperties -VMHostDscResource $vmHostDscResource

    foreach ($vmHostDscResourceProperty in $vmHostDscResourceProperties) {
        $propertyName = $vmHostDscResourceProperty.Name
        $propertyValue = $VMHostDscGetMethodResult.$propertyName

        if ($vmHostDscResourceProperty.PropertyType -eq '[string]') { Push-StringPropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[bool]') { Push-BoolPropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[string[]]') { Push-StringArrayPropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[Int32]' -or $vmHostDscResourceProperty.PropertyType -eq '[Int64]' -or $vmHostDscResourceProperty.PropertyType -eq '[double]') {
            Push-ValueTypePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue
        }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[Nullable`1]') {
            if ($propertyValue -is [bool]) { Push-BoolPropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
            else { Push-ValueTypePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[HashTable]') { Push-HashtablePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
    }

    <#
        Depending on the type of DependsOn in the Get method result, the dependencies are
        appended to the configuration content differently: for array of dependencies, each dependency in
        the array is appended with quotes. Otherwise the single dependency is appended with quotes.
    #>
    if ($null -ne $VMHostDscGetMethodResult.DependsOn) {
        if ($VMHostDscGetMethodResult.DependsOn -is [array]) {
            [void] $script:vmHostDscConfigContent.Append("                DependsOn = @(")
            for ($i = 0; $i -lt $VMHostDscGetMethodResult.DependsOn.Length; $i++) {
                if ($i -eq $VMHostDscGetMethodResult.DependsOn.Length - 1) {
                    [void] $script:vmHostDscConfigContent.Append("'$($VMHostDscGetMethodResult.DependsOn[$i])'")
                }
                else {
                    [void] $script:vmHostDscConfigContent.Append("'$($VMHostDscGetMethodResult.DependsOn[$i])', ")
                }
            }
            [void] $script:vmHostDscConfigContent.Append(")`r`n")
        }
        else {
            [void] $script:vmHostDscConfigContent.Append("                DependsOn = '$($VMHostDscGetMethodResult.DependsOn)'`r`n")
        }
    }

    [void] $script:vmHostDscConfigContent.Append("            }`r`n`r`n")
}

<#
.SYNOPSIS
Checks if the specified VMHost DSC Resource should be exported.

.DESCRIPTION
Checks if the specified VMHost DSC Resource should be exported. If the VMHost DSC Resource is specified
in the VMHostDscResourcesToExport array or the array is not passed, the VMHost DSC Resource will be exported.
Otherwise the VMHost DSC Resource will not be exported.

.PARAMETER VMHostDscResourceName
The name of the VMHost DSC Resource that will be checked whether to be exported.
#>
function Test-ExportVMHostDscResource {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostDscResourceName
    )

    $result = $false
    if ($VMHostDscResourcesToExport.Count -eq 0 -or $VMHostDscResourcesToExport -Contains $VMHostDscResourceName) {
        $result = $true
    }

    $result
}

<#
.SYNOPSIS
Reads the information about the specified DSC Resource and exposes it in the VMHost DSC Configuration.

.DESCRIPTION
Reads the information about the specified DSC Resource and exposes it in the VMHost DSC Configuration.
The user is notified with a message about the currently exported VMHost DSC Resource.

.PARAMETER VMHostDscResourceName
The name of the VMHost DSC Resource that is going to be exposed in the VMHost DSC Configuration.

.PARAMETER Message
The message that is shown to the user when the specified VMHost DSC Resource is exported.
#>
function Read-VMHostDscResourceInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostDscResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName $VMHostDscResourceName)) {
        return
    }

    Write-Host $Message -BackgroundColor DarkGreen -ForegroundColor White

    $vmHostDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
    }

    $vmHostDscResource = New-Object -TypeName $VMHostDscResourceName -Property $vmHostDscResourceKeyProperties
    $getMethodResult = $vmHostDscResource.Get()

    New-VMHostDscResourceBlock -VMHostDscResourceName $VMHostDscResourceName -VMHostDscResourceInstanceName $VMHostDscResourceName -VMHostDscGetMethodResult $getMethodResult
}

<#
.DESCRIPTION

Reads the information about SCSI devices on the specified VMHost and exposes them in the VMHost DSC Configuration
with the VMHostScsiLun DSC Resource.
#>
function Read-ScsiDevices {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostScsiLun')) {
        return
    }

    Write-Host "Retrieving information about SCSI devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    Get-ScsiDevices

    if ($script:scsiLuns.Length -gt 0) {
        Write-Warning -Message 'DeletePartitions property of VMHostScsiLun DSC Resource will not be exported in the configuration.'
    }

    foreach ($scsiLun in $script:scsiLuns) {
        $vmHostScsiLunDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            CanonicalName = $scsiLun.CanonicalName
        }

        $vmHostScsiLunDscResource = New-Object -TypeName 'VMHostScsiLun' -Property $vmHostScsiLunDscResourceKeyProperties
        $vmHostScsiLunDscResourceGetMethodResult = $vmHostScsiLunDscResource.Get()

        # The DSC engine requires a required resource name to be in the format '[<typename>]<name>', with alphanumeric characters, spaces, '_', '-', '.' and '\'.
        $formattedScsiLunCanonicalName = $scsiLun.CanonicalName -Replace ':', ''

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostScsiLun' -VMHostDscResourceInstanceName "VMHostScsiLun_$formattedScsiLunCanonicalName" -VMHostDscGetMethodResult $vmHostScsiLunDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about paths to SCSI devices on the specified VMHost and exposes them in the VMHost DSC Configuration
with the VMHostScsiLunPath DSC Resource.
#>
function Read-ScsiDevicesPaths {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostScsiLunPath')) {
        return
    }

    Write-Host "Retrieving information about paths to SCSI devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    Get-ScsiDevices

    foreach ($scsiLun in $script:scsiLuns) {
        $scsiLunPaths = Get-ScsiLunPath -ScsiLun $scsiLun -ErrorAction Stop -Verbose:$false
        foreach ($scsiLunPath in $scsiLunPaths) {
            $vmHostScsiLunPathDscResourceKeyProperties = @{
                Server = $Server
                Credential = $Credential
                VMHostName = $VMHostName
                Name = $scsiLunPath.Name
                ScsiLunCanonicalName = $scsiLun.CanonicalName
            }

            $vmHostScsiLunPathDscResource = New-Object -TypeName 'VMHostScsiLunPath' -Property $vmHostScsiLunPathDscResourceKeyProperties
            $vmHostScsiLunPathDscResourceGetMethodResult = $vmHostScsiLunPathDscResource.Get()

            if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostScsiLun') {
                # The DSC engine requires a required resource name to be in the format '[<typename>]<name>', with alphanumeric characters, spaces, '_', '-', '.' and '\'.
                $formattedScsiLunCanonicalName = $scsiLun.CanonicalName -Replace ':', ''

                $vmHostScsiLunPathDscResourceResult = @{
                    Name = $vmHostScsiLunPathDscResourceGetMethodResult.Name
                    ScsiLunCanonicalName = $vmHostScsiLunPathDscResourceGetMethodResult.ScsiLunCanonicalName
                    Active = $vmHostScsiLunPathDscResourceGetMethodResult.Active
                    Preferred = $vmHostScsiLunPathDscResourceGetMethodResult.Preferred
                    DependsOn = "[VMHostScsiLun]VMHostScsiLun_$formattedScsiLunCanonicalName"
                }

                New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostScsiLunPath' -VMHostDscResourceInstanceName "VMHostScsiLunPath_$($scsiLunPath.Name)" -VMHostDscGetMethodResult $vmHostScsiLunPathDscResourceResult
            }
            else {
                New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostScsiLunPath' -VMHostDscResourceInstanceName "VMHostScsiLunPath_$($scsiLunPath.Name)" -VMHostDscGetMethodResult $vmHostScsiLunPathDscResourceGetMethodResult
            }
        }
    }
}

<#
.DESCRIPTION

Reads the information about iSCSI Host Bus Adapters on the specified VMHost and exposes them in the VMHost DSC Configuration
with the VMHostIScsiHba DSC Resource.
#>
function Read-IScsiHbas {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostIScsiHba')) {
        return
    }

    Write-Host "Retrieving information about iSCSI Host Bus Adapters on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    Get-IScsiHostBusAdapters

    if ($script:iScsiHbas.Length -gt 0) {
        Write-Warning -Message 'Force, ChapPassword and MutualChapPassword properties of VMHostIScsiHba DSC Resource will not be exported in the configuration.'
        if ($script:vSphereDscResourcesPropertiesToExclude -NotContains 'ChapPassword') { $script:vSphereDscResourcesPropertiesToExclude += 'ChapPassword' }
        if ($script:vSphereDscResourcesPropertiesToExclude -NotContains 'MutualChapPassword') { $script:vSphereDscResourcesPropertiesToExclude += 'MutualChapPassword' }
    }

    foreach ($iScsiHba in $script:iScsiHbas) {
        $vmHostIScsiHbaDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $iScsiHba.Name
        }

        $vmHostIScsiHbaDscResource = New-Object -TypeName 'VMHostIScsiHba' -Property $vmHostIScsiHbaDscResourceKeyProperties
        $vmHostIScsiHbaDscResourceGetMethodResult = $vmHostIScsiHbaDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIScsiHba' -VMHostDscResourceInstanceName "VMHostIScsiHba_$($iScsiHba.Name)" -VMHostDscGetMethodResult $vmHostIScsiHbaDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about iSCSI Host Bus Adapter targets on the specified VMHost and exposes them in the VMHost DSC Configuration
with the VMHostIScsiHbaTarget DSC Resource.
#>
function Read-IScsiHbaTargets {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostIScsiHbaTarget')) {
        return
    }

    Write-Host "Retrieving information about iSCSI Host Bus Adapter targets on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    Get-IScsiHostBusAdapters

    if ($script:iScsiHbas.Length -gt 0) {
        Write-Warning -Message 'Force, ChapPassword and MutualChapPassword properties of VMHostIScsiHbaTarget DSC Resource will not be exported in the configuration.'
        if ($script:vSphereDscResourcesPropertiesToExclude -NotContains 'ChapPassword') { $script:vSphereDscResourcesPropertiesToExclude += 'ChapPassword' }
        if ($script:vSphereDscResourcesPropertiesToExclude -NotContains 'MutualChapPassword') { $script:vSphereDscResourcesPropertiesToExclude += 'MutualChapPassword' }
    }

    foreach ($iScsiHba in $script:iScsiHbas) {
        $iScsiHbaTargets = Get-IScsiHbaTarget -Server $script:viServer -IScsiHba $iScsiHba -ErrorAction Stop -Verbose:$false
        foreach ($iScsiHbaTarget in $iScsiHbaTargets) {
            $vmHostIScsiHbaTargetDscResourceKeyProperties = @{
                Server = $Server
                Credential = $Credential
                VMHostName = $VMHostName
                Address = $iScsiHbaTarget.Address
                Port = $iScsiHbaTarget.Port
                IScsiHbaName = $iScsiHba.Name
                TargetType = $iScsiHbaTarget.Type
            }

            $vmHostIScsiHbaTargetDscResource = New-Object -TypeName 'VMHostIScsiHbaTarget' -Property $vmHostIScsiHbaTargetDscResourceKeyProperties
            $vmHostIScsiHbaTargetDscResourceGetMethodResult = $vmHostIScsiHbaTargetDscResource.Get()

            if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostIScsiHba') {
                $vmHostIScsiHbaTargetDscResourceResult = @{
                    Address = $vmHostIScsiHbaTargetDscResourceGetMethodResult.Address
                    Port = $vmHostIScsiHbaTargetDscResourceGetMethodResult.Port
                    IScsiHbaName = $vmHostIScsiHbaTargetDscResourceGetMethodResult.IScsiHbaName
                    TargetType = $vmHostIScsiHbaTargetDscResourceGetMethodResult.TargetType
                    Ensure = $vmHostIScsiHbaTargetDscResourceGetMethodResult.Ensure
                    IScsiName = $vmHostIScsiHbaTargetDscResourceGetMethodResult.IScsiName
                    InheritChap = $vmHostIScsiHbaTargetDscResourceGetMethodResult.InheritChap
                    ChapType = $vmHostIScsiHbaTargetDscResourceGetMethodResult.ChapType
                    ChapName = $vmHostIScsiHbaTargetDscResourceGetMethodResult.ChapName
                    InheritMutualChap = $vmHostIScsiHbaTargetDscResourceGetMethodResult.InheritMutualChap
                    MutualChapEnabled = $vmHostIScsiHbaTargetDscResourceGetMethodResult.MutualChapEnabled
                    MutualChapName = $vmHostIScsiHbaTargetDscResourceGetMethodResult.MutualChapName
                    DependsOn = "[VMHostIScsiHba]VMHostIScsiHba_$($iScsiHba.Name)"
                }

                New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIScsiHbaTarget' -VMHostDscResourceInstanceName "VMHostIScsiHbaTarget_$($iScsiHbaTarget.Address):$($iScsiHbaTarget.Port)_$($iScsiHbaTarget.Type)" -VMHostDscGetMethodResult $vmHostIScsiHbaTargetDscResourceResult
            }
            else {
                New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIScsiHbaTarget' -VMHostDscResourceInstanceName "VMHostIScsiHbaTarget_$($iScsiHbaTarget.Address):$($iScsiHbaTarget.Port)_$($iScsiHbaTarget.Type)" -VMHostDscGetMethodResult $vmHostIScsiHbaTargetDscResourceGetMethodResult
            }
        }
    }
}

<#
.DESCRIPTION

Reads the information about Datastores on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VmfsDatastore and NfsDatastore DSC Resources.
#>
function Read-Datastores {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VmfsDatastore') -and !(Test-ExportVMHostDscResource -VMHostDscResourceName 'NfsDatastore')) {
        return
    }

    Write-Host "Retrieving information about Datastores on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $datastores = Get-Datastore -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    foreach ($datastore in $datastores) {
        $datastoreDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $datastore.Name
        }

        if ($datastore.Type -eq 'VMFS' -and (Test-ExportVMHostDscResource -VMHostDscResourceName 'VmfsDatastore')) {
            $datastoreDscResourceKeyProperties.Path = $datastore.ExtensionData.Info.Vmfs.Extent.DiskName
            $vmfsDatastoreDscResource = New-Object -TypeName 'VmfsDatastore' -Property $datastoreDscResourceKeyProperties
            $vmfsDatastoreDscResourceGetMethodResult = $vmfsDatastoreDscResource.Get()

            if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostScsiLun') {
                # The DSC engine requires a required resource name to be in the format '[<typename>]<name>', with alphanumeric characters, spaces, '_', '-', '.' and '\'.
                $formattedScsiLunCanonicalName = $vmfsDatastoreDscResourceGetMethodResult.Path -Replace ':', ''

                $vmfsDatastoreDscResourceResult = @{
                    Name = $vmfsDatastoreDscResourceGetMethodResult.Name
                    Path = $vmfsDatastoreDscResourceGetMethodResult.Path
                    Ensure = $vmfsDatastoreDscResourceGetMethodResult.Ensure
                    FileSystemVersion = $vmfsDatastoreDscResourceGetMethodResult.FileSystemVersion
                    BlockSizeMB = $vmfsDatastoreDscResourceGetMethodResult.BlockSizeMB
                    CongestionThresholdMillisecond = $vmfsDatastoreDscResourceGetMethodResult.CongestionThresholdMillisecond
                    StorageIOControlEnabled = $vmfsDatastoreDscResourceGetMethodResult.StorageIOControlEnabled
                    DependsOn = "[VMHostScsiLun]VMHostScsiLun_$formattedScsiLunCanonicalName"
                }

                New-VMHostDscResourceBlock -VMHostDscResourceName 'VmfsDatastore' -VMHostDscResourceInstanceName "VmfsDatastore_$($datastore.Name)" -VMHostDscGetMethodResult $vmfsDatastoreDscResourceResult
            }
            else {
                New-VMHostDscResourceBlock -VMHostDscResourceName 'VmfsDatastore' -VMHostDscResourceInstanceName "VmfsDatastore_$($datastore.Name)" -VMHostDscGetMethodResult $vmfsDatastoreDscResourceGetMethodResult
            }
        }
        elseif ($datastore.Type -eq 'NFS' -and (Test-ExportVMHostDscResource -VMHostDscResourceName 'NfsDatastore')) {
            $datastoreDscResourceKeyProperties.NfsHost = $datastore.RemoteHost
            $datastoreDscResourceKeyProperties.Path = $datastore.RemotePath
            $nfsDatastoreDscResource = New-Object -TypeName 'NfsDatastore' -Property $datastoreDscResourceKeyProperties
            $nfsDatastoreDscResourceGetMethodResult = $nfsDatastoreDscResource.Get()

            New-VMHostDscResourceBlock -VMHostDscResourceName 'NfsDatastore' -VMHostDscResourceInstanceName "NfsDatastore_$($datastore.Name)" -VMHostDscGetMethodResult $nfsDatastoreDscResourceGetMethodResult
        }
    }
}

<#
.DESCRIPTION

Reads the information about Physical Network Adapters on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostPhysicalNic DSC Resource.
#>
function Read-VMHostPhysicalNetworkAdapters {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostPhysicalNic')) {
        return
    }

    Write-Host "Retrieving information about Physical Network Adapters on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $physicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $script:viServer -VMHost $script:vmHost -Physical -ErrorAction Stop -Verbose:$false

    foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
        $vmHostPhysicalNicDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $physicalNetworkAdapter.Name
        }

        $vmHostPhysicalNicDscResource = New-Object -TypeName 'VMHostPhysicalNic' -Property $vmHostPhysicalNicDscResourceKeyProperties
        $vmHostPhysicalNicDscResourceGetMethodResult = $vmHostPhysicalNicDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostPhysicalNic' -VMHostDscResourceInstanceName "VMHostPhysicalNic_$($physicalNetworkAdapter.Name)" -VMHostDscGetMethodResult $vmHostPhysicalNicDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about Standard Switches on the specified VMHost and exposes it in the VMHost DSC Configuration
with the StandardSwitch Composite DSC Resource.
#>
function Read-StandardSwitches {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'StandardSwitch')) {
        return
    }

    Write-Host "Retrieving information about Standard Switches on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $standardSwitches = Get-VirtualSwitch -Server $script:viServer -VMHost $script:vmHost -Standard -ErrorAction Stop -Verbose:$false

    foreach ($standardSwitch in $standardSwitches) {
        $vmHostVssDscResourcesKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = $standardSwitch.Name
        }

        $vmHostVssDscResource = New-Object -TypeName 'VMHostVss' -Property $vmHostVssDscResourcesKeyProperties
        $vmHostVssDscResourceGetMethodResult = $vmHostVssDscResource.Get()

        $vmHostVssBridgeDscResource = New-Object -TypeName 'VMHostVssBridge' -Property $vmHostVssDscResourcesKeyProperties
        $vmHostVssBridgeDscResourceGetMethodResult = $vmHostVssBridgeDscResource.Get()

        $vmHostVssSecurityDscResource = New-Object -TypeName 'VMHostVssSecurity' -Property $vmHostVssDscResourcesKeyProperties
        $vmHostVssSecurityDscResourceGetMethodResult = $vmHostVssSecurityDscResource.Get()

        $vmHostVssShapingDscResource = New-Object -TypeName 'VMHostVssShaping' -Property $vmHostVssDscResourcesKeyProperties
        $vmHostVssShapingDscResourceGetMethodResult = $vmHostVssShapingDscResource.Get()

        $vmHostVssTeamingDscResource = New-Object -TypeName 'VMHostVssTeaming' -Property $vmHostVssDscResourcesKeyProperties
        $vmHostVssTeamingDscResourceGetMethodResult = $vmHostVssTeamingDscResource.Get()

        <#
            If only one NIC device is bridged to the Standard Switch, the DependsOn type is 'string'.
            Otherwise for more than one NIC device the type is 'string[]'.
        #>
        $standardSwitchDscResourceDependencies = $null
        if ($vmHostVssBridgeDscResourceGetMethodResult.NicDevice.Length -ne 0) {
            if ($vmHostVssBridgeDscResourceGetMethodResult.NicDevice.Length -eq 1) {
                $standardSwitchDscResourceDependencies = "[VMHostPhysicalNic]VMHostPhysicalNic_$($vmHostVssBridgeDscResourceGetMethodResult.NicDevice)"
            }
            else {
                $standardSwitchDscResourceDependencies = @()
                for ($i = 0; $i -lt $vmHostVssBridgeDscResourceGetMethodResult.NicDevice.Length; $i++) {
                    $standardSwitchDscResourceDependencies += "[VMHostPhysicalNic]VMHostPhysicalNic_$($vmHostVssBridgeDscResourceGetMethodResult.NicDevice[$i])"
                }
            }
        }

        $standardSwitchDscResourceResult = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $standardSwitch.Name
            Ensure = $vmHostVssDscResourceGetMethodResult.Ensure
            Mtu = $vmHostVssDscResourceGetMethodResult.Mtu
            NicDevice = $vmHostVssBridgeDscResourceGetMethodResult.NicDevice
            BeaconInterval = $vmHostVssBridgeDscResourceGetMethodResult.BeaconInterval
            LinkDiscoveryProtocolType = $vmHostVssBridgeDscResourceGetMethodResult.LinkDiscoveryProtocolProtocol
            LinkDiscoveryProtocolOperation = $vmHostVssBridgeDscResourceGetMethodResult.LinkDiscoveryProtocolOperation
            AllowPromiscuous = $vmHostVssSecurityDscResourceGetMethodResult.AllowPromiscuous
            ForgedTransmits = $vmHostVssSecurityDscResourceGetMethodResult.ForgedTransmits
            MacChanges = $vmHostVssSecurityDscResourceGetMethodResult.MacChanges
            AverageBandwidth = $vmHostVssShapingDscResourceGetMethodResult.AverageBandwidth
            BurstSize = $vmHostVssShapingDscResourceGetMethodResult.BurstSize
            Enabled = $vmHostVssShapingDscResourceGetMethodResult.Enabled
            PeakBandwidth = $vmHostVssShapingDscResourceGetMethodResult.PeakBandwidth
            CheckBeacon = $vmHostVssTeamingDscResourceGetMethodResult.CheckBeacon
            ActiveNic = $vmHostVssTeamingDscResourceGetMethodResult.ActiveNic
            StandbyNic = $vmHostVssTeamingDscResourceGetMethodResult.StandbyNic
            NotifySwitches = $vmHostVssTeamingDscResourceGetMethodResult.NotifySwitches
            Policy = $vmHostVssTeamingDscResourceGetMethodResult.Policy
            RollingOrder = $vmHostVssTeamingDscResourceGetMethodResult.RollingOrder
        }

        if ($null -ne $standardSwitchDscResourceDependencies -and (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostPhysicalNic')) {
            $standardSwitchDscResourceResult.DependsOn = $standardSwitchDscResourceDependencies
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'StandardSwitch' -VMHostDscResourceInstanceName "StandardSwitch_$($standardSwitch.Name)" -VMHostDscGetMethodResult $standardSwitchDscResourceResult
    }
}

<#
.DESCRIPTION

Reads the information about Standard Port Groups on the specified VMHost and exposes it in the VMHost DSC Configuration
with the StandardPortGroup Composite DSC Resource.
#>
function Read-StandardPortGroups {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'StandardPortGroup')) {
        return
    }

    Write-Host "Retrieving information about Standard Port Groups on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $standardPortGroups = Get-VirtualPortGroup -Server $script:viServer -VMHost $script:vmHost -Standard -ErrorAction Stop -Verbose:$false

    foreach ($standardPortGroup in $standardPortGroups) {
        $vmHostVssPortGroupDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $standardPortGroup.Name
            VssName = $standardPortGroup.VirtualSwitchName
        }

        $vmHostVssPortGroupDscResourcesKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $standardPortGroup.Name
        }

        $vmHostVssPortGroupDscResource = New-Object -TypeName 'VMHostVssPortGroup' -Property $vmHostVssPortGroupDscResourceKeyProperties
        $vmHostVssPortGroupDscResourceGetMethodResult = $vmHostVssPortGroupDscResource.Get()

        $vmHostVssPortGroupSecurityDscResource = New-Object -TypeName 'VMHostVssPortGroupSecurity' -Property $vmHostVssPortGroupDscResourcesKeyProperties
        $vmHostVssPortGroupSecurityDscResourceGetMethodResult = $vmHostVssPortGroupSecurityDscResource.Get()

        $vmHostVssPortGroupShapingDscResource = New-Object -TypeName 'VMHostVssPortGroupShaping' -Property $vmHostVssPortGroupDscResourcesKeyProperties
        $vmHostVssPortGroupShapingDscResourceGetMethodResult = $vmHostVssPortGroupShapingDscResource.Get()

        $vmHostVssPortGroupTeamingDscResource = New-Object -TypeName 'VMHostVssPortGroupTeaming' -Property $vmHostVssPortGroupDscResourcesKeyProperties
        $vmHostVssPortGroupTeamingDscResourceGetMethodResult = $vmHostVssPortGroupTeamingDscResource.Get()

        $standardPortGroupDscResourceResult = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $standardPortGroup.Name
            VssName = $standardPortGroup.VirtualSwitchName
            Ensure = $vmHostVssPortGroupDscResourceGetMethodResult.Ensure
            VLanId = $vmHostVssPortGroupDscResourceGetMethodResult.VLanId
            AllowPromiscuous = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.AllowPromiscuous
            AllowPromiscuousInherited = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.AllowPromiscuousInherited
            ForgedTransmits = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.ForgedTransmits
            ForgedTransmitsInherited = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.ForgedTransmitsInherited
            MacChanges = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.MacChanges
            MacChangesInherited = $vmHostVssPortGroupSecurityDscResourceGetMethodResult.MacChangesInherited
            Enabled = $vmHostVssPortGroupShapingDscResourceGetMethodResult.Enabled
            AverageBandwidth = $vmHostVssPortGroupShapingDscResourceGetMethodResult.AverageBandwidth
            PeakBandwidth = $vmHostVssPortGroupShapingDscResourceGetMethodResult.PeakBandwidth
            BurstSize = $vmHostVssPortGroupShapingDscResourceGetMethodResult.BurstSize
            FailbackEnabled = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.FailbackEnabled
            LoadBalancingPolicy = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.LoadBalancingPolicy
            ActiveNic = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.ActiveNic
            StandbyNic = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.StandbyNic
            UnusedNic = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.UnusedNic
            NetworkFailoverDetectionPolicy = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.NetworkFailoverDetectionPolicy
            InheritFailback = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.InheritFailback
            InheritFailoverOrder = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.InheritFailoverOrder
            InheritLoadBalancingPolicy = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.InheritLoadBalancingPolicy
            InheritNetworkFailoverDetectionPolicy = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.InheritNetworkFailoverDetectionPolicy
            InheritNotifySwitches = $vmHostVssPortGroupTeamingDscResourceGetMethodResult.InheritNotifySwitches
        }

        if (Test-ExportVMHostDscResource -VMHostDscResourceName 'StandardSwitch') {
            $standardPortGroupDscResourceResult.DependsOn = "[StandardSwitch]StandardSwitch_$($standardPortGroup.VirtualSwitchName)"
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'StandardPortGroup' -VMHostDscResourceInstanceName "StandardPortGroup_$($standardPortGroup.Name)" -VMHostDscGetMethodResult $standardPortGroupDscResourceResult
    }
}

<#
.DESCRIPTION

Reads the information about VMKernel Network Adapters on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostVssNic DSC Resource.
#>
function Read-VMKernelNetworkAdapters {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostVssNic')) {
        return
    }

    Write-Host "Retrieving information about VMKernel Network Adapters on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $script:viServer -VMHost $script:vmHost -VMKernel -ErrorAction Stop -Verbose:$false

    foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
        $getVirtualPortGroupParams = @{
            Server = $script:viServer
            VMHost = $script:vmHost
            Name = $vmKernelNetworkAdapter.PortGroupName
            Standard = $true
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $portGroup = Get-VirtualPortGroup @getVirtualPortGroupParams
        if ($null -eq $portGroup) {
            # The Port Group is a Distributed Port Group, so the VMKernel Network Adapter should not be exported through the VMHostVssNic DSC Resource.
            continue
        }

        $vmHostVssNicDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = $portGroup.VirtualSwitchName
            PortGroupName = $vmKernelNetworkAdapter.PortGroupName
        }

        $vmHostVssNicDscResource = New-Object -TypeName 'VMHostVssNic' -Property $vmHostVssNicDscResourceKeyProperties
        $vmHostVssNicDscResourceGetMethodResult = $vmHostVssNicDscResource.Get()

        if ($vmHostVssNicDscResourceGetMethodResult.Ensure.ToString() -eq 'Absent') {
            <#
                There could be a Distributed and Standard Port Groups with the same name and
                the VMKernel Network Adapter could be connected to the Distributed Port Group. So the VMHostVssNic will
                not find a VMKernel Network Adapter for the Standard Port Group and Switch and it should be skipped in the
                exported configuration.
            #>
            continue
        }

        if (Test-ExportVMHostDscResource -VMHostDscResourceName 'StandardPortGroup') {
            $vmHostVssNicDscResourceResult = @{
                VssName = $vmHostVssNicDscResourceGetMethodResult.VssName
                PortGroupName = $vmHostVssNicDscResourceGetMethodResult.PortGroupName
                Ensure = $vmHostVssNicDscResourceGetMethodResult.Ensure
                Dhcp = $vmHostVssNicDscResourceGetMethodResult.Dhcp
                IP = $vmHostVssNicDscResourceGetMethodResult.IP
                SubnetMask = $vmHostVssNicDscResourceGetMethodResult.SubnetMask
                Mac = $vmHostVssNicDscResourceGetMethodResult.Mac
                AutomaticIPv6 = $vmHostVssNicDscResourceGetMethodResult.AutomaticIPv6
                IPv6 = $vmHostVssNicDscResourceGetMethodResult.IPv6
                IPv6ThroughDhcp = $vmHostVssNicDscResourceGetMethodResult.IPv6ThroughDhcp
                Mtu = $vmHostVssNicDscResourceGetMethodResult.Mtu
                IPv6Enabled = $vmHostVssNicDscResourceGetMethodResult.IPv6Enabled
                ManagementTrafficEnabled = $vmHostVssNicDscResourceGetMethodResult.ManagementTrafficEnabled
                FaultToleranceLoggingEnabled = $vmHostVssNicDscResourceGetMethodResult.FaultToleranceLoggingEnabled
                VMotionEnabled = $vmHostVssNicDscResourceGetMethodResult.VMotionEnabled
                VsanTrafficEnabled = $vmHostVssNicDscResourceGetMethodResult.VsanTrafficEnabled
                DependsOn = "[StandardPortGroup]StandardPortGroup_$($vmKernelNetworkAdapter.PortGroupName)"
            }

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostVssNic' -VMHostDscResourceInstanceName "VMHostVssNic_$($vmKernelNetworkAdapter.Name)" -VMHostDscGetMethodResult $vmHostVssNicDscResourceResult
        }
        else {
            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostVssNic' -VMHostDscResourceInstanceName "VMHostVssNic_$($vmKernelNetworkAdapter.Name)" -VMHostDscGetMethodResult $vmHostVssNicDscResourceGetMethodResult
        }
    }
}

<#
.DESCRIPTION

Reads the information about DNS settings on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostDnsSettings DSC Resource.
#>
function Read-VMHostDnsSettings {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostDnsSettings')) {
        return
    }

    Write-Host "Retrieving information about DNS settings on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White

    $vmHostDnsSettingsDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
    }

    $vmHostDnsSettingsDscResource = New-Object -TypeName 'VMHostDnsSettings' -Property $vmHostDnsSettingsDscResourceKeyProperties
    $vmHostDnsSettingsDscResourceGetMethodResult = $vmHostDnsSettingsDscResource.Get()

    if (
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostVssNic') -and
        (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice) -or
        ![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice))
    ) {
        $vmHostDnsSettingsDscResourceDependencies = @()
        if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice)) {
            $vmHostDnsSettingsDscResourceDependencies += "[VMHostVssNic]VMHostVssNic_$($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice)"
        }

        if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice) -and $vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice -ne $vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice) {
            $vmHostDnsSettingsDscResourceDependencies += "[VMHostVssNic]VMHostVssNic_$($vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice)"
        }

        $vmHostDnsSettingsDscResourceResult = @{
            Address = $vmHostDnsSettingsDscResourceGetMethodResult.Address
            Dhcp = $vmHostDnsSettingsDscResourceGetMethodResult.Dhcp
            DomainName = $vmHostDnsSettingsDscResourceGetMethodResult.DomainName
            HostName = $vmHostDnsSettingsDscResourceGetMethodResult.HostName
            Ipv6VirtualNicDevice = $vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice
            SearchDomain = $vmHostDnsSettingsDscResourceGetMethodResult.SearchDomain
            VirtualNicDevice = $vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice
            DependsOn = $vmHostDnsSettingsDscResourceDependencies
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostDnsSettings' -VMHostDscResourceInstanceName 'VMHostDnsSettings' -VMHostDscGetMethodResult $vmHostDnsSettingsDscResourceResult
    }
    else {
        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostDnsSettings' -VMHostDscResourceInstanceName 'VMHostDnsSettings' -VMHostDscGetMethodResult $vmHostDnsSettingsDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about IP Routes on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostIPRoute DSC Resource.
#>
function Read-VMHostIPRoutes {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostIPRoute')) {
        return
    }

    Write-Host "Retrieving information about IP Routes on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $ipRoutes = Get-VMHostRoute -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    foreach ($ipRoute in $ipRoutes) {
        $vmHostIPRouteDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Gateway = $ipRoute.Gateway
            Destination = $ipRoute.Destination
            PrefixLength = $ipRoute.PrefixLength
        }

        $vmHostIPRouteDscResource = New-Object -TypeName 'VMHostIPRoute' -Property $vmHostIPRouteDscResourceKeyProperties
        $vmHostIPRouteDscResourceGetMethodResult = $vmHostIPRouteDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIPRoute' -VMHostDscResourceInstanceName "VMHostIPRoute_$($ipRoute.Gateway)_$($ipRoute.Destination)" -VMHostDscGetMethodResult $vmHostIPRouteDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about network core dump configuration on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostNetworkCoreDump DSC Resource.
#>
function Read-VMHostNetworkCoreDump {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostNetworkCoreDump')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) network core dump configuration..." -BackgroundColor DarkGreen -ForegroundColor White

    $vmHostNetworkCoreDumpDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
    }

    $vmHostNetworkCoreDumpDscResource = New-Object -TypeName 'VMHostNetworkCoreDump' -Property $vmHostNetworkCoreDumpDscResourceKeyProperties
    $vmHostNetworkCoreDumpDscResourceGetMethodResult = $vmHostNetworkCoreDumpDscResource.Get()

    if (
        ![string]::IsNullOrEmpty($vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName) -and
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostVssNic')
    ) {
        $vmHostNetworkCoreDumpDscResourceResult = @{
            Enable = $vmHostNetworkCoreDumpDscResourceGetMethodResult.Enable
            InterfaceName = $vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName
            ServerIp = $vmHostNetworkCoreDumpDscResourceGetMethodResult.ServerIp
            ServerPort = $vmHostNetworkCoreDumpDscResourceGetMethodResult.ServerPort
            DependsOn = "[VMHostVssNic]VMHostVssNic_$($vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName)"
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostNetworkCoreDump' -VMHostDscResourceInstanceName 'VMHostNetworkCoreDump' -VMHostDscGetMethodResult $vmHostNetworkCoreDumpDscResourceResult
    }
    else {
        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostNetworkCoreDump' -VMHostDscResourceInstanceName 'VMHostNetworkCoreDump' -VMHostDscGetMethodResult $vmHostNetworkCoreDumpDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about advanced settings on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostAdvancedSettings DSC Resource.
#>
function Read-VMHostAdvancedSettings {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAdvancedSettings')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) advanced settings..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostAdvancedSettings = Get-AdvancedSetting -Server $script:viServer -Entity $script:vmHost -ErrorAction Stop -Verbose:$false
    $advancedSettings = @{}

    foreach ($vmHostAdvancedSetting in $vmHostAdvancedSettings) {
        $advancedSettingName = $vmHostAdvancedSetting.Name
        $advancedSettingValue = $vmHostAdvancedSetting.Value
        $advancedSettings.$advancedSettingName = $advancedSettingValue
    }

    $vmHostAdvancedSettingsDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
        AdvancedSettings = $advancedSettings
    }

    $vmHostAdvancedSettingsDscResource = New-Object -TypeName 'VMHostAdvancedSettings' -Property $vmHostAdvancedSettingsDscResourceKeyProperties
    $vmHostAdvancedSettingsDscResourceGetMethodResult = $vmHostAdvancedSettingsDscResource.Get()

    New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostAdvancedSettings' -VMHostDscResourceInstanceName 'VMHostAdvancedSettings' -VMHostDscGetMethodResult $vmHostAdvancedSettingsDscResourceGetMethodResult
}

<#
.DESCRIPTION

Reads the information about graphics devices on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostGraphicsDevice DSC Resource.
#>
function Read-VMHostGraphicsDevices {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostGraphicsDevice')) {
        return
    }

    Write-Host "Retrieving information about graphics devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostGraphicsManager = Get-View -Server $script:viServer -Id $script:vmHost.ExtensionData.ConfigManager.GraphicsManager -ErrorAction Stop -Verbose:$false
    $graphicsDevices = $vmHostGraphicsManager.GraphicsConfig.DeviceType

    foreach ($graphicsDevice in $graphicsDevices) {
        $vmHostGraphicsDeviceDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Id = $graphicsDevice.DeviceId
        }

        $vmHostGraphicsDeviceDscResource = New-Object -TypeName 'VMHostGraphicsDevice' -Property $vmHostGraphicsDeviceDscResourceKeyProperties
        $vmHostGraphicsDeviceDscResourceGetMethodResult = $vmHostGraphicsDeviceDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostGraphicsDevice' -VMHostDscResourceInstanceName "VMHostGraphicsDevice_$($graphicsDevice.DeviceId)" -VMHostDscGetMethodResult $vmHostGraphicsDeviceDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about software devices, VMKernel modules, vSan network configuration and VMKernel dump files on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostSoftwareDevice, VMHostVMKernelModule, VMHostvSANNetworkConfiguration and VMHostVMKernelDumpFile DSC Resources.
#>
function Read-VMHostEsxCliInfo {
    $esxCli = Get-EsxCli -Server $script:viServer -VMHost $script:vmHost -V2 -ErrorAction Stop -Verbose:$false

    # If no software devices are present on the VMHost, an exception will be thrown when the Invoke() method is executed.
    if (
        $null -ne $esxCli.device.software.list -and
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostSoftwareDevice')
    ) {
        Write-Host "Retrieving information about software devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
        $vmHostSoftwareDevices = $esxCli.device.software.list.Invoke()
        foreach ($vmHostSoftwareDevice in $vmHostSoftwareDevices) {
            $vmHostSoftwareDeviceDscResourceKeyProperties = @{
                Server = $Server
                Credential = $Credential
                Name = $VMHostName
                DeviceIdentifier = $vmHostSoftwareDevice.DeviceID
            }

            $vmHostSoftwareDeviceDscResource = New-Object -TypeName 'VMHostSoftwareDevice' -Property $vmHostSoftwareDeviceDscResourceKeyProperties
            $vmHostSoftwareDeviceDscResourceGetMethodResult = $vmHostSoftwareDeviceDscResource.Get()

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostSoftwareDevice' -VMHostDscResourceInstanceName "VMHostSoftwareDevice_$($vmHostSoftwareDevice.DeviceID)" -VMHostDscGetMethodResult $vmHostSoftwareDeviceDscResourceGetMethodResult
        }
    }

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostVMKernelModule') {
        Write-Host "Retrieving information about VMKernel modules on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
        $vmHostVMKernelModules = $esxCli.system.module.list.Invoke()

        if ($vmHostVMKernelModules.Length -gt 0) {
            Write-Warning -Message 'Force property of VMHostVMKernelModule DSC Resource will not be exported in the configuration.'
        }

        foreach ($vmHostVMKernelModule in $vmHostVMKernelModules) {
            $vmHostVMKernelModuleDscResourceKeyProperties = @{
                Server = $Server
                Credential = $Credential
                Name = $VMHostName
                Module = $vmHostVMKernelModule.Name
            }

            $vmHostVMKernelModuleDscResource = New-Object -TypeName 'VMHostVMKernelModule' -Property $vmHostVMKernelModuleDscResourceKeyProperties
            $vmHostVMKernelModuleDscResourceGetMethodResult = $vmHostVMKernelModuleDscResource.Get()

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostVMKernelModule' -VMHostDscResourceInstanceName "VMHostVMKernelModule_$($vmHostVMKernelModule.Name)" -VMHostDscGetMethodResult $vmHostVMKernelModuleDscResourceGetMethodResult
        }
    }

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostvSANNetworkConfiguration') {
        Write-Host "Retrieving information about vSan network configuration on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
        $vmHostvSanNetworkConfigurations = $esxCli.vsan.network.list.Invoke()

        if ($null -ne $vmHostvSanNetworkConfigurations.VmkNicName) {
            Write-Warning -Message 'Force property of VMHostvSANNetworkConfiguration DSC Resource will not be exported in the configuration.'
            foreach ($vmHostvSanNetworkConfiguration in $vmHostvSanNetworkConfigurations) {
                if ($null -ne $vmHostvSanNetworkConfiguration) {
                    $vmHostvSANNetworkConfigurationDscResourceKeyProperties = @{
                        Server = $Server
                        Credential = $Credential
                        Name = $VMHostName
                        InterfaceName = $vmHostvSanNetworkConfiguration.VmkNicName
                    }

                    $vmHostvSANNetworkConfigurationDscResource = New-Object -TypeName 'VMHostvSANNetworkConfiguration' -Property $vmHostvSANNetworkConfigurationDscResourceKeyProperties
                    $vmHostvSANNetworkConfigurationDscResourceGetMethodResult = $vmHostvSANNetworkConfigurationDscResource.Get()

                    New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostvSANNetworkConfiguration' -VMHostDscResourceInstanceName "VMHostvSANNetworkConfiguration_$($vmHostvSanNetworkConfiguration.VmkNicName)" -VMHostDscGetMethodResult $vmHostvSANNetworkConfigurationDscResourceGetMethodResult
                }
            }
        }
    }

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostVMKernelDumpFile') {
        Write-Host "Retrieving information about VMKernel dump files on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
        $vmHostVMKernelDumpFiles = $esxCli.system.coredump.file.list.Invoke()

        if ($null -ne $vmHostVMKernelDumpFiles.Path) {
            foreach ($vmHostVMKernelDumpFile in $vmHostVMKernelDumpFiles) {
                $vmHostVMKernelDumpFileParts = $vmHostVMKernelDumpFile.Path -Split '/'
                $vmHostVMKernelDumpFileName = ($vmHostVMKernelDumpFileParts[5] -Split '\.')[0]
                $vmHostVMKernelDumpFileDatastoreName = $null

                $fileSystems = $esxCli.storage.filesystem.list.Invoke(@{})
                foreach ($fileSystem in $fileSystems) {
                    if ($fileSystem.UUID -eq $vmHostVMKernelDumpFileParts[3] -or $fileSystem.VolumeName -eq $vmHostVMKernelDumpFileParts[3]) {
                        $vmHostVMKernelDumpFileDatastoreName = $fileSystem.VolumeName
                        break
                    }
                }

                $vmHostVMKernelDumpFileDscResourceKeyProperties = @{
                    Server = $Server
                    Credential = $Credential
                    Name = $VMHostName
                    DatastoreName = $vmHostVMKernelDumpFileDatastoreName
                    FileName = $vmHostVMKernelDumpFileName
                }

                $vmHostVMKernelDumpFileDscResource = New-Object -TypeName 'VMHostVMKernelDumpFile' -Property $vmHostVMKernelDumpFileDscResourceKeyProperties
                $vmHostVMKernelDumpFileDscResourceGetMethodResult = $vmHostVMKernelDumpFileDscResource.Get()

                New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostVMKernelDumpFile' -VMHostDscResourceInstanceName "VMHostVMKernelDumpFile_$($vmHostVMKernelDumpFileDatastoreName)_$vmHostVMKernelDumpFileName" -VMHostDscGetMethodResult $vmHostVMKernelDumpFileDscResourceGetMethodResult
            }
        }
    }
}

<#
.DESCRIPTION

Reads the information about Services on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostService DSC Resource.
#>
function Read-VMHostServices {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostService')) {
        return
    }

    Write-Host "Retrieving information about Services on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostServices = Get-VMHostService -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    foreach ($vmHostService in $vmHostServices) {
        $vmHostServiceDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Key = $vmHostService.Key
        }

        $vmHostServiceDscResource = New-Object -TypeName 'VMHostService' -Property $vmHostServiceDscResourceKeyProperties
        $vmHostServiceDscResourceGetMethodResult = $vmHostServiceDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostService' -VMHostDscResourceInstanceName "VMHostService_$($vmHostService.Key)" -VMHostDscGetMethodResult $vmHostServiceDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about firewall rulesets on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostFirewallRuleset DSC Resource.
#>
function Read-VMHostFirewallRulesets {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostFirewallRuleset')) {
        return
    }

    Write-Host "Retrieving information about firewall rulesets on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostFirewallRulesets = Get-VMHostFirewallException -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    foreach ($vmHostFirewallRuleset in $vmHostFirewallRulesets) {
        $vmHostFirewallRulesetDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $vmHostFirewallRuleset.Name
        }

        $vmHostFirewallRulesetDscResource = New-Object -TypeName 'VMHostFirewallRuleset' -Property $vmHostFirewallRulesetDscResourceKeyProperties
        $vmHostFirewallRulesetDscResourceGetMethodResult = $vmHostFirewallRulesetDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostFirewallRuleset' -VMHostDscResourceInstanceName "VMHostFirewallRuleset_$($vmHostFirewallRuleset.Name)" -VMHostDscGetMethodResult $vmHostFirewallRulesetDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about Pci passthrough devices on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostPciPassthrough DSC Resource.
#>
function Read-VMHostPciPassthrough {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostPciPassthrough')) {
        return
    }

    Write-Host "Retrieving information about Pci passthrough devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostPciPassthruSystem = Get-View -Server $script:viServer -Id $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem -ErrorAction Stop -Verbose:$false
    $vmHostPciDevices = $vmHostPciPassthruSystem.PciPassthruInfo | Where-Object -FilterScript { $_.PassthruCapable }

    foreach ($vmHostPciDevice in $vmHostPciDevices) {
        $vmHostPciPassthroughDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Id = $vmHostPciDevice.Id
        }

        $vmHostPciPassthroughDscResource = New-Object -TypeName 'VMHostPciPassthrough' -Property $vmHostPciPassthroughDscResourceKeyProperties
        $vmHostPciPassthroughDscResourceGetMethodResult = $vmHostPciPassthroughDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostPciPassthrough' -VMHostDscResourceInstanceName "VMHostPciPassthrough_$($vmHostPciDevice.Name)" -VMHostDscGetMethodResult $vmHostPciPassthroughDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about cache on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostCache DSC Resource.
#>
function Read-VMHostCache {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostCache')) {
        return
    }

    Write-Host "Retrieving information about cache on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostCacheConfigurationManager = Get-View -Server $script:viServer -Id $script:vmHost.ExtensionData.ConfigManager.CacheConfigurationManager -ErrorAction Stop -Verbose:$false
    $vmHostCacheConfigurationDatastores = $vmHostCacheConfigurationManager.CacheConfigurationInfo.Key

    foreach ($vmHostCacheConfigurationDatastoreMoRef in $vmHostCacheConfigurationDatastores) {
        $datastoreName = Get-Datastore -Server $script:viServer -VMHost $script:vmHost |
                         Where-Object -FilterScript { $_.ExtensionData.MoRef -eq $vmHostCacheConfigurationDatastoreMoRef } |
                         Select-Object -ExpandProperty Name

        $vmHostCacheDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            DatastoreName = $datastoreName
        }

        $vmHostCacheDscResource = New-Object -TypeName 'VMHostCache' -Property $vmHostCacheDscResourceKeyProperties
        $vmHostCacheDscResourceGetMethodResult = $vmHostCacheDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostCache' -VMHostDscResourceInstanceName "VMHostCache_$datastoreName" -VMHostDscGetMethodResult $vmHostCacheDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about roles on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostRole DSC Resource.
#>
function Read-VMHostRoles {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostRole')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) roles..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostRoles = Get-VIRole -Server $script:viServer -ErrorAction Stop -Verbose:$false

    foreach ($vmHostRole in $vmHostRoles) {
        $vmHostRoleDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Name = $vmHostRole.Name
        }

        $vmHostRoleDscResource = New-Object -TypeName 'VMHostRole' -Property $vmHostRoleDscResourceKeyProperties
        $vmHostRoleDscResourceGetMethodResult = $vmHostRoleDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostRole' -VMHostDscResourceInstanceName "VMHostRole_$($vmHostRole.Name)" -VMHostDscGetMethodResult $vmHostRoleDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about accounts on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostAccount DSC Resource.
#>
function Read-VMHostAccounts {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAccount')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) accounts..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostAccounts = Get-VMHostAccount -Server $script:viServer -ErrorAction Stop -Verbose:$false

    if ($vmHostAccounts.Length -gt 0) {
        Write-Warning -Message 'AccountPassword property of VMHostAccount DSC Resource will not be exported in the configuration.'
        $script:vSphereDscResourcesPropertiesToExclude += 'AccountPassword'
    }

    foreach ($vmHostAccount in $vmHostAccounts) {
        $vmHostAccountDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            Id = $vmHostAccount.Id
        }

        $vmHostAccountDscResource = New-Object -TypeName 'VMHostAccount' -Property $vmHostAccountDscResourceKeyProperties
        $vmHostAccountDscResourceGetMethodResult = $vmHostAccountDscResource.Get()

        if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostRole') {
            $vmHostAccountDscResourceResult = @{
                Id = $vmHostAccountDscResourceGetMethodResult.Id
                Ensure = $vmHostAccountDscResourceGetMethodResult.Ensure
                Role = $vmHostAccountDscResourceGetMethodResult.Role
                Description = $vmHostAccountDscResourceGetMethodResult.Description
                DependsOn = "[VMHostRole]VMHostRole_$($vmHostAccountDscResourceGetMethodResult.Role)"
            }

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostAccount' -VMHostDscResourceInstanceName "VMHostAccount_$($vmHostAccount.Id)" -VMHostDscGetMethodResult $vmHostAccountDscResourceResult
        }
        else {
            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostAccount' -VMHostDscResourceInstanceName "VMHostAccount_$($vmHostAccount.Id)" -VMHostDscGetMethodResult $vmHostAccountDscResourceGetMethodResult
        }
    }
}

<#
.DESCRIPTION
Retrieves the location of the specified Entity. Location consists of 0 or more Inventory Items.
Inventory Item names in the location are separated by '/'.

.PARAMETER Entity
The Entity which location needs to be retrieved.
#>
function Get-EntityLocation {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]
        $Entity
    )

    $entityLocationAsArray = @()

    if ($null -ne $Entity.Parent) {
        $entityParent = $Entity.Parent

        while ($null -ne $entityParent) {
            $entityLocationAsArray += $entityParent
            $entityParent = $entityParent.Parent
        }
    }

    # The Parent of the Entity should be the last element in the array.
    [array]::Reverse($entityLocationAsArray)
    $entityLocationAsArray -Join '/'
}

<#
.DESCRIPTION
Retrieves the type of the specified Entity. Valid Entity types are: 'Datacenter', 'VMHost', 'Datastore', 'VM', 'ResourcePool' and 'VApp'.

.PARAMETER Entity
The Entity which type needs to be retrieved.
#>
function Get-EntityType {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]
        $Entity
    )

    $entityTypeNamespace = $Entity.GetType().FullName.Split('.')
    $entityTypeName = $entityTypeNamespace[$entityTypeNamespace.Length - 1]

    $entityType = $entityTypeName -Replace 'Impl', ''

    <#
        If the Entity type is a 'Folder', the Entity is the default root folder of the VMHost which is not a valid Entity type.
        So the Entity type should be modified to 'VMHost'.
    #>
    if ($entityType -eq 'Folder') {
        $entityType = 'VMHost'
    }
    elseif ($entityType -Match 'Datastore') {
        # The extracted Datastore type is either 'VmfsDatastore' or 'NasDatastore'.
        $entityType = 'Datastore'
    }
    elseif ($entityType -eq 'VirtualMachine') {
        $entityType = 'VM'
    }

    $entityType
}

<#
.DESCRIPTION

Reads the information about permissions on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostPermission DSC Resource.
#>
function Read-VMHostPermissions {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostPermission')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) permissions..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmHostPermissions = Get-VIPermission -Server $script:viServer -ErrorAction Stop -Verbose:$false

    foreach ($vmHostPermission in $vmHostPermissions) {
        $permissionEntity = $vmHostPermission.Entity

        $entityName = $permissionEntity.Name
        $entityLocation = Get-EntityLocation -Entity $permissionEntity
        $entityType = Get-EntityType -Entity $permissionEntity
        $principalName = $vmHostPermission.Principal

        $vmHostPermissionDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            EntityName = $entityName
            EntityLocation = $entityLocation
            EntityType = $entityType
            PrincipalName = $principalName
        }

        $vmHostPermissionDscResource = New-Object -TypeName 'VMHostPermission' -Property $vmHostPermissionDscResourceKeyProperties
        $vmHostPermissionDscResourceGetMethodResult = $vmHostPermissionDscResource.Get()

        $vmHostPermissionDscResourceDependencies = $null

        if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAccount') {
            if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostRole') {
                $vmHostPermissionDscResourceDependencies = @("[VMHostAccount]VMHostAccount_$principalName")
            }
            else {
                $vmHostPermissionDscResourceDependencies = "[VMHostAccount]VMHostAccount_$principalName"
            }
        }

        # Permission could exist without a Role.
        if (
            ![string]::IsNullOrEmpty($vmHostPermissionDscResourceGetMethodResult.RoleName) -and
            (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostRole')
        ) {
            $vmHostPermissionDscResourceDependencies += "[VMHostRole]VMHostRole_$($vmHostPermissionDscResourceGetMethodResult.RoleName)"
        }

        $vmHostPermissionDscResourceResult = @{
            Id = $vmHostPermissionDscResourceGetMethodResult.Id
            EntityName = $vmHostPermissionDscResourceGetMethodResult.EntityName
            EntityLocation = $vmHostPermissionDscResourceGetMethodResult.EntityLocation
            EntityType = $vmHostPermissionDscResourceGetMethodResult.EntityType
            PrincipalName = $vmHostPermissionDscResourceGetMethodResult.PrincipalName
            RoleName = $vmHostPermissionDscResourceGetMethodResult.RoleName
            Ensure = $vmHostPermissionDscResourceGetMethodResult.Ensure
            Propagate = $vmHostPermissionDscResourceGetMethodResult.Propagate
        }

        if ($null -ne $vmHostPermissionDscResourceDependencies) {
            $vmHostPermissionDscResourceResult.DependsOn = $vmHostPermissionDscResourceDependencies
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostPermission' -VMHostDscResourceInstanceName "VMHostPermission_$($entityName)_$principalName" -VMHostDscGetMethodResult $vmHostPermissionDscResourceResult
    }
}

<#
.DESCRIPTION

Reads the information about NFS user accounts on the specified VMHost and exposes them in the VMHost DSC Configuration
with the NfsUser DSC Resource.
#>
function Read-NfsUserAccounts {
    if (!(Test-ExportVMHostDscResource -VMHostDscResourceName 'NfsUser')) {
        return
    }

    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) NFS user accounts..." -BackgroundColor DarkGreen -ForegroundColor White
    $nfsUser = Get-NfsUser -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    $nfsUserDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $nfsUser.Username
    }

    $nfsUserDscResource = New-Object -TypeName 'NfsUser' -Property $nfsUserDscResourceKeyProperties
    $nfsUserDscResourceGetMethodResult = $nfsUserDscResource.Get()

    Write-Warning -Message 'Password and Force properties of NfsUser DSC Resource will not be exported in the configuration.'
    $script:vSphereDscResourcesPropertiesToExclude += 'Password'

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAuthentication') {
        $nfsUserDscResourceResult = @{
            Name = $nfsUserDscResourceGetMethodResult.Name
            Ensure = $nfsUserDscResourceGetMethodResult.Ensure
            Force = $nfsUserDscResourceGetMethodResult.Force
            DependsOn = "[VMHostAuthentication]VMHostAuthentication"
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'NfsUser' -VMHostDscResourceInstanceName 'NfsUser' -VMHostDscGetMethodResult $nfsUserDscResourceResult
    }
    else {
        New-VMHostDscResourceBlock -VMHostDscResourceName 'NfsUser' -VMHostDscResourceInstanceName 'NfsUser' -VMHostDscGetMethodResult $nfsUserDscResourceGetMethodResult
    }
}

<#
.DESCRIPTION

Reads the information about authentication on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostRole, VMHostAccount, VMHostPermission, VMHostAuthentication and NfsUser DSC Resources.
#>
function Read-VMHostAuthentication {
    if (
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostRole') -or
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAccount') -or
        (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostPermission')
    ) {
        if ($script:viServer.ProductLine -eq 'embeddedEsx') {
            Read-VMHostRoles
            Read-VMHostAccounts
            Read-VMHostPermissions
        }
        else {
            Write-Warning -Message "VMHost $($script:vmHost) accounts, roles and permissions cannot be exported into the configuration because the connection is to vCenter Server instance. Connect directly to the ESXi to export them."
        }
    }

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAuthentication') {
        Write-Host "Retrieving information about VMHost $($script:vmHost.Name) authentication..." -BackgroundColor DarkGreen -ForegroundColor White
        $vmHostAuthenticationInfo = Get-VMHostAuthentication -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

        if ($null -ne $vmHostAuthenticationInfo.Domain) {
            $vmHostAuthenticationDscResourceKeyProperties = @{
                Server = $Server
                Credential = $Credential
                Name = $VMHostName
                DomainName = $vmHostAuthenticationInfo.Domain
                DomainAction = 'Join'
            }

            $vmHostAuthenticationDscResource = New-Object -TypeName 'VMHostAuthentication' -Property $vmHostAuthenticationDscResourceKeyProperties
            $vmHostAuthenticationDscResourceGetMethodResult = $vmHostAuthenticationDscResource.Get()

            Write-Warning -Message 'DomainCredential property of VMHostAuthentication DSC Resource will not be exported in the configuration.'
            $script:vSphereDscResourcesPropertiesToExclude += 'DomainCredential'

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostAuthentication' -VMHostDscResourceInstanceName 'VMHostAuthentication' -VMHostDscGetMethodResult $vmHostAuthenticationDscResourceGetMethodResult
        }
    }

    Read-NfsUserAccounts
}

<#
.DESCRIPTION

The main function for reading the current VMHost configuration. It acts as a call dispatcher, calling all required functions
in the proper order to read the whole information of the VMHost that is exposed as DSC Resources.
#>
function Read-VMHostConfiguration {
    $script:availableVSphereDscResources = Get-DscResource -Module 'VMware.vSphereDSC' -ErrorAction Stop -Verbose:$false
    $script:vSphereDscResourcesPropertiesToExclude = @('Server', 'Credential', 'DependsOn', 'PsDscRunAsCredential')

    # VMHost Storage DSC Resources
    Read-ScsiDevices
    Read-ScsiDevicesPaths
    Read-IScsiHbas
    Read-IScsiHbaTargets
    Read-Datastores

    # VMHost Network DSC Resources
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostNtpSettings' -Message "Retrieving information about NTP settings on VMHost $($script:vmHost)..."

    Read-VMHostPhysicalNetworkAdapters
    Read-StandardSwitches
    Read-StandardPortGroups
    Read-VMKernelNetworkAdapters
    Read-VMHostDnsSettings
    Read-VMHostIPRoutes
    Read-VMHostNetworkCoreDump

    # VMHost settings DSC Resources
    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostConfiguration') {
        if ($script:vmHost.VMSwapfilePolicy.ToString() -eq 'Inherit') {
            Write-Warning -Message "VMHost configuration with swapfile placement policy 'Inherited' will not be exported in the configuration."
        }
        else {
            Write-Warning -Message 'Evacuate property of VMHostConfiguration DSC Resource will not be exported in the configuration.'
            Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostConfiguration' -Message "Retrieving information about VMHost $($script:vmHost.Name) configuration..."
        }
    }

    Read-VMHostAdvancedSettings

    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostTpsSettings' -Message "Retrieving information about TPS settings on VMHost $($script:vmHost)..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostSettings' -Message "Retrieving information about VMHost $($script:vmHost.Name) settings..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostPowerPolicy' -Message "Retrieving information about VMHost $($script:vmHost.Name) power policy..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostGraphics' -Message "Retrieving information about VMHost $($script:vmHost.Name) graphics settings..."

    Read-VMHostGraphicsDevices

    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostSyslog' -Message "Retrieving information about VMHost $($script:vmHost.Name) syslog settings..."

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostSNMPAgent') {
        Write-Warning -Message 'Reset property of VMHostSNMPAgent DSC Resource will not be exported in the configuration.'
        Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostSNMPAgent' -Message "Retrieving information about VMHost $($script:vmHost.Name) SNMP agent settings..."
    }

    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostSharedSwapSpace' -Message "Retrieving information about VMHost $($script:vmHost.Name) shared swap space settings..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostDCUIKeyboard' -Message "Retrieving information about VMHost $($script:vmHost.Name) DCUI keyboard..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostAcceptanceLevel' -Message "Retrieving information about VMHost $($script:vmHost.Name) acceptance level..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostVMKernelActiveDumpPartition' -Message "Retrieving information about VMHost $($script:vmHost.Name) VMKernel active dump partition settings..."
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostVMKernelActiveDumpFile' -Message "Retrieving information about VMHost $($script:vmHost.Name) VMKernel active dump file settings..."

    Write-Warning -Message "VMHost $($script:vmHost) SATP Claim Rules are not exported into the configuration."

    Read-VMHostEsxCliInfo
    Read-VMHostServices
    Read-VMHostFirewallRulesets
    Read-VMHostPciPassthrough
    Read-VMHostCache
    Read-VMHostAuthentication

    if (Test-ExportVMHostDscResource -VMHostDscResourceName 'VMHostAgentVM') {
        if ($script:viServer.ProductLine -eq 'vpx') {
            Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostAgentVM' -Message "Retrieving information about VMHost $($script:vmHost.Name) AgentVM settings..."
        }
        else {
            Write-Warning -Message "VMHost $($script:vmHost) AgentVM settings cannot be exported into the configuration because the connection is to ESXi. Connect directly to vCenter Server instance to export them."
        }
    }
}

<#
.DESCRIPTION

Returns the path to the output file of the VMHost DSC Configuration.
#>
function Get-VMHostDscConfigurationOutputFile {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $vmHostDscConfigurationOutputFile = $OutputPath
    if (!$OutputPath.EndsWith('\') -and !$OutputPath.EndsWith('/')) {
        $vmHostDscConfigurationOutputFile += '\'
    }

    $vmHostDscConfigurationOutputFile += $script:vmHostConfigurationFileName
    $vmHostDscConfigurationOutputFile
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

    Read-VMHostConfiguration

    [void] $script:vmHostDscConfigContent.Append("        }`r`n")

    [void] $script:vmHostDscConfigContent.Append("    }`r`n")
    [void] $script:vmHostDscConfigContent.Append("}`r`n`r`n")

    [void] $script:vmHostDscConfigContent.Append("$script:vmHostConfigurationName -ConfigurationData `$script:configurationData")

    $outputFile = Get-VMHostDscConfigurationOutputFile
    $script:vmHostDscConfigContent.ToString() | Out-File -FilePath $outputFile -Encoding Default

    Disconnect-VSphereServer
}

Export-VMHostConfiguration
