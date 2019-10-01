<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class BaseDSC {
    <#
    .DESCRIPTION

    Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi.
    #>
    [DscProperty(Key)]
    [string] $Server

    <#
    .DESCRIPTION

    Credentials needed for connection to the specified Server.
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $Credential

    <#
    .DESCRIPTION

    Established connection to the specified vSphere Server.
    #>
    hidden [PSObject] $Connection

    hidden [string] $vCenterProductId = 'vpx'

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Connects to the specified Server with the passed Credentials.
    The method sets the Connection property to the established connection.
    If connection cannot be established, the method writes an error.
    #>
    [void] ConnectVIServer() {
        $this.ImportRequiredModules()

        if ($null -eq $this.Connection) {
            try {
                $this.Connection = Connect-VIServer -Server $this.Server -Credential $this.Credential -ErrorAction Stop
            }
            catch {
                throw "Cannot establish connection to server $($this.Server). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Checks if the passed array is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateArraySetting($currentArray, $desiredArray) {
        if ($null -eq $desiredArray) {
            # The property is not specified.
            return $false
        }
        elseif ($desiredArray.Length -eq 0 -and $currentArray.Length -ne 0) {
            # Empty array specified as desired, but current is not an empty array, so update should be performed.
            return $true
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
                return $true
            }

            # No need to perform an update operation.
            return $false
        }
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
}
