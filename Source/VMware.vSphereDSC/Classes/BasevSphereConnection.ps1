<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class BasevSphereConnection {
    <#
    .DESCRIPTION

    Credentials needed for connection to the specified Server.
    #>
    [DscProperty()]
    [PSCredential] $Credential

    <#
    .DESCRIPTION

    Established connection to the specified vSphere Server.
    #>
    [PSObject] $Connection

    hidden [string] $DscResourceName = $this.GetType().Name
    hidden [string] $DscResourceIsInDesiredStateMessage = "{0} DSC Resource is in Desired State."
    hidden [string] $DscResourceIsNotInDesiredStateMessage = "{0} DSC Resource is not in Desired State."

    hidden [string] $TestMethodStartMessage = "Begin executing Test functionality for {0} DSC Resource."
    hidden [string] $TestMethodEndMessage = "End executing Test functionality for {0} DSC Resource."
    hidden [string] $SetMethodStartMessage = "Begin executing Set functionality for {0} DSC Resource."
    hidden [string] $SetMethodEndMessage = "End executing Set functionality for {0} DSC Resource."
    hidden [string] $GetMethodStartMessage = "Begin executing Get functionality for {0} DSC Resource."
    hidden [string] $GetMethodEndMessage = "End executing Get functionality for {0} DSC Resource."

    hidden [string] $SettingIsNotInDesiredStateMessage = "Setting {0}: Current setting value [ {1} ] does not match desired setting value [ {2} ]."
    hidden [string] $DscResourcesEnumDefaultValue = 'Unset'

    hidden [string] $vCenterProductId = 'vpx'
    hidden [string] $ESXiProductId = 'embeddedEsx'

    <#
    .DESCRIPTION

    Imports the required modules where the used PowerCLI cmdlets reside.
    #>
    [void] ImportRequiredModules() {
        <#
            The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
            when importing the 'VMware.VimAutomation.Core' Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name 'VMware.VimAutomation.Core'

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Checks if the passed array is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateArraySetting($settingName, $currentArray, $desiredArray) {
        $result = $null

        if ($null -eq $desiredArray) {
            # The property is not specified.
            $result = $false
        }
        elseif ($desiredArray.Length -eq 0 -and $currentArray.Length -ne 0) {
            # Empty array specified as desired, but current is not an empty array, so update should be performed.
            Write-VerboseLog -Message $this.SettingIsNotInDesiredStateMessage -Arguments @($settingName, ($currentArray -Join ', '), ($desiredArray -Join ', '))
            $result = $true
        }
        else {
            $elementsToAdd = $desiredArray | Where-Object { $currentArray -NotContains $_ }
            $elementsToRemove = $currentArray | Where-Object { $desiredArray -NotContains $_ }

            if ($null -ne $elementsToAdd -or $null -ne $elementsToRemove) {
                <#
                    The current array does not contain at least one element from desired array or
                    the desired array is a subset of the current array. In both cases
                    we should perform an update operation.
                #>
                Write-VerboseLog -Message $this.SettingIsNotInDesiredStateMessage -Arguments @($settingName, ($currentArray -Join ', '), ($desiredArray -Join ', '))
                $result = $true
            }
            else {
                # No need to perform an update operation.
                $result = $false
            }
        }

        return $result
    }

    <#
    .DESCRIPTION

    Checks if the passed setting is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateDscResourceSetting($settingName, $currentSetting, $desiredSetting) {
        $result = $null

        if ($this.$settingName -is [string]) {
            $result = ($null -ne $desiredSetting -and $desiredSetting -ne [string] $currentSetting)
        }
        elseif ($this.$settingName -is [enum]) {
            $result = ($desiredSetting -ne $this.DscResourcesEnumDefaultValue -and $desiredSetting -ne $currentSetting)
        }
        else {
            $result = ($null -ne $desiredSetting -and $desiredSetting -ne $currentSetting)
        }

        if ($result) {
            Write-VerboseLog -Message $this.SettingIsNotInDesiredStateMessage -Arguments @($settingName, $currentSetting, $desiredSetting)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Checks if the Connection is directly to a vCenter and if not, throws an exception.
    #>
    [void] EnsureConnectionIsvCenter() {
        if ($this.Connection.ProductLine -ne $this.vCenterProductId) {
            throw 'The Resource operations are only supported when connection is directly to a vCenter.'
        }
    }

    <#
    .DESCRIPTION

    Checks if the Connection is directly to an ESXi host and if not, throws an exception.
    #>
    [void] EnsureConnectionIsESXi() {
        if ($this.Connection.ProductLine -ne $this.ESXiProductId) {
            throw 'The Resource operations are only supported when connection is directly to an ESXi host.'
        }
    }

    <#
    .DESCRIPTION

    Writes a Verbose message specifying if the DSC Resource is in the Desired State.
    #>
    [void] WriteDscResourceState($result) {
        if ($result) {
            Write-VerboseLog -Message $this.DscResourceIsInDesiredStateMessage -Arguments @($this.DscResourceName)
        }
        else {
            Write-VerboseLog -Message $this.DscResourceIsNotInDesiredStateMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VIObject is of the specified type.
    #>
    [bool] IsVIObjectOfTheCorrectType($viObject, $typeAsString) {
        $result = $false
        $viObjectType = $viObject.GetType()

        if ($viObjectType.FullName -eq $typeAsString) {
            $result = $true
        }
        elseif (($viObjectType.GetInterfaces().FullName -eq $typeAsString).Length -gt 0) {
            $result = $true
        }
        else {
            $baseType = $viObjectType.BaseType

            while ($null -ne $baseType) {
                if ($baseType.FullName -eq $typeAsString) {
                    $result = $true
                    break
                }

                $baseType = $baseType.BaseType
            }
        }

        return $result
    }

    <#
    .DESCRIPTION

    Connects to the specified vSphere Server with the passed Credentials.
    The method sets the Connection property to the established connection.
    If connection cannot be established, the method throws an exception.
    #>
    [void] ConnectVIServer() {
        $this.ImportRequiredModules()

        if ($null -eq $this.Connection) {
            try {
                $connectVIServerParams = @{
                    Server = $this.Server
                    Credential = $this.Credential
                    ErrorAction = 'Stop'
                    Verbose = $false
                }

                $this.Connection = Connect-VIServer @connectVIServerParams
            }
            catch {
                throw "Cannot establish connection to vSphere Server $($this.Server). For more information: $($_.Exception.Message)"
            }
        } else {
            # this is a connection from a vSphereDSC node
            # a new connection with the same session and server name get created because of an issue with runspaces in PowerShell 

            $this.Connection = Connect-VIServer -Session $this.Connection.SessionSecret -Server $this.Connection.Name
        }
    }

    <#
    .DESCRIPTION

    Closes the last open connection to the specified vSphere Server.
    #>
    [void] DisconnectVIServer() {
        try {
            $disconnectVIServerParams = @{
                Server = $this.Connection
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }

            Disconnect-VIServer @disconnectVIServerParams
        }
        catch {
            throw "Cannot close connection to vSphere Server $($this.Connection.Name). For more information: $($_.Exception.Message)"
        }
    }
}
