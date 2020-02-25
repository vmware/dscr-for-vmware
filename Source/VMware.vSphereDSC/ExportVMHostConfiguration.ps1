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
