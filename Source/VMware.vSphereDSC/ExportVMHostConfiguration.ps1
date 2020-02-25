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
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[Int32]' -or $vmHostDscResourceProperty.PropertyType -eq '[Int64]') { Push-ValueTypePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[Nullable`1]') {
            if ($propertyValue -is [bool]) { Push-BoolPropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
            else { Push-ValueTypePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
        }
        elseif ($vmHostDscResourceProperty.PropertyType -eq '[HashTable]') { Push-HashtablePropertyToVMHostDscResourceBlock -PropertyName $propertyName -PropertyValue $propertyValue }
    }

    if ($null -ne $VMHostDscGetMethodResult.DependsOn) { [void] $script:vmHostDscConfigContent.Append("                DependsOn = '$($VMHostDscGetMethodResult.DependsOn)'`r`n") }

    [void] $script:vmHostDscConfigContent.Append("            }`r`n`r`n")
}

<#
.DESCRIPTION
Reads the information about the specified DSC Resource and exposes it in the VMHost DSC Configuration.

.PARAMETER VMHostDscResourceName
The name of the VMHost DSC Resource that is going to be exposed in the VMHost DSC Configuration.
#>
function Read-VMHostDscResourceInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostDscResourceName
    )

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

Reads the information about SCSI devices and paths to the SCSI devices on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostScsiLun and VMHostScsiLunPath DSC Resources.
#>
function Read-ScsiDevices {
    Write-Host "Retrieving information about SCSI devices and paths to the SCSI devices on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $scsiLuns = Get-ScsiLun -Server $script:viServer -VmHost $script:vmHost -ErrorAction Stop -Verbose:$false

    if ($scsiLuns.Length -gt 0) {
        Write-Warning -Message 'DeletePartitions property of VMHostScsiLun DSC Resource will not be exported in the configuration.'
    }

    foreach ($scsiLun in $scsiLuns) {
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

            $vmHostScsiLunPathDscResourceResult = @{
                Name = $vmHostScsiLunPathDscResourceGetMethodResult.Name
                ScsiLunCanonicalName = $vmHostScsiLunPathDscResourceGetMethodResult.ScsiLunCanonicalName
                Active = $vmHostScsiLunPathDscResourceGetMethodResult.Active
                Preferred = $vmHostScsiLunPathDscResourceGetMethodResult.Preferred
                DependsOn = "[VMHostScsiLun]VMHostScsiLun_$formattedScsiLunCanonicalName"
            }

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostScsiLunPath' -VMHostDscResourceInstanceName "VMHostScsiLunPath_$($scsiLunPath.Name)" -VMHostDscGetMethodResult $vmHostScsiLunPathDscResourceResult
        }
    }
}

<#
.DESCRIPTION

Reads the information about iSCSI Host Bus Adapters and iSCSI Host Bus Adapter targets on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostIScsiHba and VMHostIScsiHbaTarget DSC Resources.
#>
function Read-IScsiHbas {
    Write-Host "Retrieving information about iSCSI Host Bus Adapters and iSCSI Host Bus Adapter targets on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $iScsiHbas = Get-VMHostHba -Server $script:viServer -VMHost $script:vmHost -Type 'iSCSI' -ErrorAction Stop -Verbose:$false

    if ($iScsiHbas.Length -gt 0) {
        Write-Warning -Message 'Force, ChapPassword and MutualChapPassword properties of VMHostIScsiHba and VMHostIScsiHbaTarget DSC Resources will not be exported in the configuration.'
        $script:vSphereDscResourcesPropertiesToExclude += 'ChapPassword'
        $script:vSphereDscResourcesPropertiesToExclude += 'MutualChapPassword'
    }

    foreach ($iScsiHba in $iScsiHbas) {
        $vmHostIScsiHbaDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $iScsiHba.Name
        }

        $vmHostIScsiHbaDscResource = New-Object -TypeName 'VMHostIScsiHba' -Property $vmHostIScsiHbaDscResourceKeyProperties
        $vmHostIScsiHbaDscResourceGetMethodResult = $vmHostIScsiHbaDscResource.Get()

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIScsiHba' -VMHostDscResourceInstanceName "VMHostIScsiHba_$($iScsiHba.Name)" -VMHostDscGetMethodResult $vmHostIScsiHbaDscResourceGetMethodResult

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
                Force = $vmHostIScsiHbaTargetDscResourceGetMethodResult.Force
                DependsOn = "[VMHostIScsiHba]VMHostIScsiHba_$($iScsiHba.Name)"
            }

            New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostIScsiHbaTarget' -VMHostDscResourceInstanceName "VMHostIScsiHbaTarget_$($iScsiHbaTarget.Address):$($iScsiHbaTarget.Port)_$($iScsiHbaTarget.Type)" -VMHostDscGetMethodResult $vmHostIScsiHbaTargetDscResourceResult
        }
    }
}

<#
.DESCRIPTION

Reads the information about Datastores on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VmfsDatastore and NfsDatastore DSC Resources.
#>
function Read-Datastores {
    Write-Host "Retrieving information about Datastores on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $datastores = Get-Datastore -Server $script:viServer -VMHost $script:vmHost -ErrorAction Stop -Verbose:$false

    foreach ($datastore in $datastores) {
        $datastoreDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $datastore.Name
        }

        if ($datastore.Type -eq 'VMFS') {
            $datastoreDscResourceKeyProperties.Path = $datastore.ExtensionData.Info.Vmfs.Extent.DiskName
            $vmfsDatastoreDscResource = New-Object -TypeName 'VmfsDatastore' -Property $datastoreDscResourceKeyProperties
            $vmfsDatastoreDscResourceGetMethodResult = $vmfsDatastoreDscResource.Get()

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
        elseif ($datastore.Type -eq 'NFS') {
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

        $standardSwitchDscResourceDependencies = ''
        for ($i = 0; $i -lt $vmHostVssBridgeDscResourceGetMethodResult.NicDevice.Length; $i++) {
            if ($i -eq $vmHostVssBridgeDscResourceGetMethodResult.NicDevice.Length - 1) {
                $standardSwitchDscResourceDependencies += "[VMHostPhysicalNic]VMHostPhysicalNic_$($vmHostVssBridgeDscResourceGetMethodResult.NicDevice[$i])"
            }
            else {
                $standardSwitchDscResourceDependencies += "[VMHostPhysicalNic]VMHostPhysicalNic_$($vmHostVssBridgeDscResourceGetMethodResult.NicDevice[$i]), "
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
            DependsOn = $standardSwitchDscResourceDependencies
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
            DependsOn = "[StandardSwitch]StandardSwitch_$($standardPortGroup.VirtualSwitchName)"
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
    Write-Host "Retrieving information about VMKernel Network Adapters on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $script:viServer -VMHost $script:vmHost -VMKernel -ErrorAction Stop -Verbose:$false

    foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
        $portGroup = Get-VirtualPortGroup -Server $script:viServer -VMHost $script:vmHost -Name $vmKernelNetworkAdapter.PortGroupName -ErrorAction Stop -Verbose:$false
        $vmHostVssNicDscResourceKeyProperties = @{
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = $portGroup.VirtualSwitchName
            PortGroupName = $vmKernelNetworkAdapter.PortGroupName
        }

        $vmHostVssNicDscResource = New-Object -TypeName 'VMHostVssNic' -Property $vmHostVssNicDscResourceKeyProperties
        $vmHostVssNicDscResourceGetMethodResult = $vmHostVssNicDscResource.Get()

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
}

<#
.DESCRIPTION

Reads the information about DNS settings on the specified VMHost and exposes it in the VMHost DSC Configuration
with the VMHostDnsSettings DSC Resource.
#>
function Read-VMHostDnsSettings {
    Write-Host "Retrieving information about DNS settings on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White

    $vmHostDnsSettingsDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
    }

    $vmHostDnsSettingsDscResource = New-Object -TypeName 'VMHostDnsSettings' -Property $vmHostDnsSettingsDscResourceKeyProperties
    $vmHostDnsSettingsDscResourceGetMethodResult = $vmHostDnsSettingsDscResource.Get()

    if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice) -or ![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice)) {
        $vmHostDnsSettingsDscResourceDependencies = ''
        if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice)) {
            $vmHostDnsSettingsDscResourceDependencies += "[VMHostVssNic]VMHostVssNic_$($vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice)"
        }

        if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice) -and $vmHostDnsSettingsDscResourceGetMethodResult.Ipv6VirtualNicDevice -ne $vmHostDnsSettingsDscResourceGetMethodResult.VirtualNicDevice) {
            if (![string]::IsNullOrEmpty($vmHostDnsSettingsDscResourceDependencies)) {
                $vmHostDnsSettingsDscResourceDependencies += ", "
            }

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
    Write-Host "Retrieving information about VMHost $($script:vmHost.Name) network core dump configuration..." -BackgroundColor DarkGreen -ForegroundColor White

    $vmHostNetworkCoreDumpDscResourceKeyProperties = @{
        Server = $Server
        Credential = $Credential
        Name = $VMHostName
    }

    $vmHostNetworkCoreDumpDscResource = New-Object -TypeName 'VMHostNetworkCoreDump' -Property $vmHostNetworkCoreDumpDscResourceKeyProperties
    $vmHostNetworkCoreDumpDscResourceGetMethodResult = $vmHostNetworkCoreDumpDscResource.Get()

    if (![string]::IsNullOrEmpty($vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName)) {
        $vmHostNetworkCoreDumpDscResourceDependencies = "[VMHostVssNic]VMHostVssNic_$($vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName)"

        $vmHostNetworkCoreDumpDscResourceResult = @{
            Enable = $vmHostNetworkCoreDumpDscResourceGetMethodResult.Enable
            InterfaceName = $vmHostNetworkCoreDumpDscResourceGetMethodResult.InterfaceName
            ServerIp = $vmHostNetworkCoreDumpDscResourceGetMethodResult.ServerIp
            ServerPort = $vmHostNetworkCoreDumpDscResourceGetMethodResult.ServerPort
            DependsOn = $vmHostNetworkCoreDumpDscResourceDependencies
        }

        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostNetworkCoreDump' -VMHostDscResourceInstanceName 'VMHostNetworkCoreDump' -VMHostDscGetMethodResult $vmHostNetworkCoreDumpDscResourceResult
    }
    else {
        New-VMHostDscResourceBlock -VMHostDscResourceName 'VMHostNetworkCoreDump' -VMHostDscResourceInstanceName 'VMHostNetworkCoreDump' -VMHostDscGetMethodResult $vmHostNetworkCoreDumpDscResourceGetMethodResult
    }
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
    Read-IScsiHbas
    Read-Datastores

    # VMHost Network DSC Resources
    Write-Host "Retrieving information about NTP settings on VMHost $($script:vmHost)..." -BackgroundColor DarkGreen -ForegroundColor White
    Read-VMHostDscResourceInfo -VMHostDscResourceName 'VMHostNtpSettings'

    Read-VMHostPhysicalNetworkAdapters
    Read-StandardSwitches
    Read-StandardPortGroups
    Read-VMKernelNetworkAdapters
    Read-VMHostDnsSettings
    Read-VMHostIPRoutes
    Read-VMHostNetworkCoreDump
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

    $outputFile = $OutputPath + $script:vmHostConfigurationFileName
    $script:vmHostDscConfigContent.ToString() | Out-File -FilePath $outputFile -Encoding Default

    Disconnect-VSphereServer
}

Export-VMHostConfiguration
