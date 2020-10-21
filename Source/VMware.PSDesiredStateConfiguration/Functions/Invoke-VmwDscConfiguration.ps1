<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.Description
Invokes the dsc resources of a configuration with 'Get' Dsc method
#>
function Get-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true)]
        [VmwDscConfiguration]
        $Configuration
    )

    $invokeParams = @{
        DscResources = $Configuration.Resources
        Method = 'Get'
    }
    
    Invoke-VmwDscResources @invokeParams
}

<#
.Description
Invokes the dsc resources of a configuration with 'Set' Dsc method
#>
function Start-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true)]
        [VmwDscConfiguration]
        $Configuration
    )

    $invokeParams = @{
        DscResources = $Configuration.Resources
        Method = 'Set'
    }
    
    Invoke-VmwDscResources @invokeParams | Out-Null
}

<#
.Description
Invokes the resources of a configuration with 'Test' Dsc method.
Returns a boolean result that shows if the current state is desired.
Use Detailed switch to return an object with state flag and information on resources and their state
#>
function Test-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true)]
        [VmwDscConfiguration]
        $Configuration,
        
        [Parameter(
        Mandatory            = $false)]
        [Switch]
        $Detailed
    )

    $invokeParams = @{
        DscResources = $Configuration.Resources
        Method = 'Test'
    }
    
    $resStateArr = Invoke-VmwDscResources @invokeParams

    $result = $null
    
    if ($Detailed) {
        $result = [DscTestMethodDetailedResult]::new($Configuration.Resources, $resStateArr)
    }
    else {
        $result = ($resStateArr | Where-Object { $_.InDesiredState -eq $false }).Count -eq 0
    }

    $result
}

<#
.Description
Invokes an array of dsc resource with the given method  
#>
function Invoke-VmwDscResources {
    param (
        [Parameter(Mandatory)]
        [VmwDscResource[]]
        $DscResources,
        
        [Parameter(Mandatory)]
        [ValidateSet('Get', 'Set', 'Test')]
        [string]
        $Method
    )

    $result = New-Object -TypeName 'System.Collections.ArrayList'

    # invoke the dsc resources
    foreach ($dscResource in $DscResources) {
        $invokeResult = $null

        if ($dscResource.GetIsComposite()) {
            $invokeVmwDscResourceParams = @{
                DscResources = $dscResource.GetInnerResources()
                Method = $Method
            }

            $invokeResult = Invoke-VmwDscResources @invokeVmwDscResourceParams
        } else {
            $invokeDscResourceUtilParams = @{
                DscResource = $dscResource
                Method = $Method
            }

            $invokeResult = InvokeDscResourceUtil @invokeDscResourceUtilParams
        }

        $result.Add($invokeResult) | Out-Null
    }

    $result.ToArray()
}

<#
.Description
Utility function wraper for invoking dsc resources
#>
function InvokeDscResourceUtil {
    param (
        [VmwDscResource]
        $DscResource,

        [string]
        $Method
    )

    # parameters used for Invoke-DscResource cmdlet
    # Method property gets set later on inside switch, because it's variable
    $invokeSplatParams = @{
        Name = $DscResource.ResourceType
        ModuleName = $DscResource.ModuleName
        Property = $DscResource.Property
    }

    $invokeResult = $null
    
    if ($Method -eq 'Test' -or $Method -eq 'Get') {
        try {
            $invokeResult = Invoke-DscResource @invokeSplatParams -Method $Method
        } catch {
            # if an exception is thrown that means the resource is not in desired state
            # due to a dependency not being in desired state
            if ($Method -eq 'Test') {
                $invokeResult = [PSCustomObject]@{
                    InDesiredState = $false
                } 
            } else {
                $invokeResult = $DscResource
            }
        }
    } 
    else {
        # checks if the resource is in target state
        $isInDesiredState = Invoke-DscResource @invokeSplatParams -Method 'Test'

        # executes 'set' method only if state is not desired
        if ($isInDesiredState.InDesiredState) {
            $invokeResult = $isInDesiredState
        }
        else {
            $invokeResult = Invoke-DscResource @invokeSplatParams -Method $Method
        }
    }

    $invokeResult
}

