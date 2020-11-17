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

$Script:LastExecutedConfiguration = $null

<#
.DESCRIPTION
Invokes the DSC Configuration with the 'Set' DSC method.
Every Resource that is not in desired state gets it's set method run.
#>
function Start-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true,
        Position             = 0)]
        [ValidateNotNullOrEmpty()]
        [VmwDscConfiguration]
        $Configuration
    )

    $invokeParams = @{
        Configuration = $Configuration
        Method = 'Set'
    }
    
    Invoke-VmwDscConfiguration @invokeParams | Out-Null
}

<#
.DESCRIPTION
Invokes the DSC Configuration with the 'Get' DSC method.
Retrieves the dsc resources current states.
#>

#> 
function Get-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true,
        ParameterSetName     = 'Explicit_Configuration',
        Position             = 0)]
        [ValidateNotNullOrEmpty()]
        [VmwDscConfiguration]
        $Configuration,

        [Parameter(
        Mandatory            = $true,
        ParameterSetName     = 'Last_Configuration',
        Position             = 0)]
        [Switch]
        $ExecuteLastConfiguration
    )

    $invokeParams = @{
        Configuration = $Configuration
        ExecuteLastConfiguration = $ExecuteLastConfiguration
        Method = 'Get'
    }
    
    $getResult = Invoke-VmwDscConfiguration @invokeParams

    $result = New-Object -TypeName 'System.Collections.ArrayList'

    foreach ($nodeStateResult in $getResult) {
        $dscGetResult = [DscGetMethodResult]::new($nodeStateResult.OriginalNode, $nodeStateResult.InvokeResult)

        $result.Add($dscGetResult) | Out-Null
    }

    $result.ToArray()
}

<#
.DESCRIPTION
Invokes the DSC Configuration with the 'Test' DSC method
Returns a boolean result that shows if the current state is desired.
Use Detailed switch to return an object with state flag and more detailed information on resources and their individual states.
#>
function Test-VmwDscConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory            = $true,
        ValueFromPipeline    = $true,
        ParameterSetName     = 'Explicit_Configuration',
        Position             = 0)]
        [ValidateNotNullOrEmpty()]
        [VmwDscConfiguration]
        $Configuration,

        [Parameter(
        Mandatory            = $true,
        ParameterSetName     = 'Last_Configuration',
        Position             = 0)]
        [Switch]
        $ExecuteLastConfiguration,
        
        [Parameter(
        Mandatory            = $false,
        Position             = 1)]
        [Switch]
        $Detailed
    )

    $invokeParams = @{
        Configuration = $Configuration
        ExecuteLastConfiguration = $ExecuteLastConfiguration
        Method = 'Test'
    }

    $testResults = Invoke-VmwDscConfiguration @invokeParams

    $result = $null

    if ($Detailed) {
        $result = New-Object -TypeName 'System.Collections.ArrayList'

        foreach ($nodeStateResult in $testResults) {
            $testResultObject = [DscTestMethodDetailedResult]::new($nodeStateResult.OriginalNode, $nodeStateResult.InvokeResult)

            $result.Add($testResultObject) | Out-Null
        }

        $result = $result.ToArray()
    } else {
        $result = ($testResults | Select-Object -ExpandProperty InvokeResult | Where-Object { $_.InDesiredState -eq $false }).Count -eq 0
    }

    $result
}

<#
.SYNOPSIS
Invokes the dsc configuration object and returns an appropriate result depending on the method used
#>
function Invoke-VmwDscConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(
        Mandatory            = $true)]
        [ValidateSet('Get', 'Set', 'Test')]
        [string]
        $Method,

        [Parameter(
        Mandatory            = $false)]
        [VmwDscConfiguration]
        $Configuration,

        [Parameter(
        Mandatory            = $false)]
        [Switch]
        $ExecuteLastConfiguration
    )

    if ($ExecuteLastConfiguration) {
        if ($null -eq $Script:LastExecutedConfiguration) {
            throw $Script:NoConfigurationDetectedForInvokeException
        }

        $Configuration = $Script:LastExecutedConfiguration
    }

    $invoker = [DscConfigurationRunner]::new($Configuration, $Method)

    $invokeResult = $invoker.InvokeConfiguration()

    $Script:LastExecutedConfiguration = $Configuration

    $invokeResult
}
