<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-EsxCliDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $esxCliBaseDSCProperties
}

function New-MocksForEsxCliBaseDSC {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileRetrievingTheEsxCliInterface {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    Mock -CommandName Get-EsxCli -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenTheEsxCliInterfaceIsRetrievedSuccessfully {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileCreatingTheArgumentsForTheEsxCliCommand {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { throw }.GetNewClosure() -ParameterFilter { $Command -eq $script:constants.EsxCliSetMethodCreateArgs } -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileInvokingTheEsxCliCommandMethod {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli
    $esxCliSetMethodArgsMock = $script:constants.EsxCliSetMethodArgs

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliSetMethodArgsMock }.GetNewClosure() -ParameterFilter { $Command -eq $script:constants.EsxCliSetMethodCreateArgs } -Verifiable
    Mock -CommandName Invoke-EsxCliCommandMethod -MockWith { throw }.GetNewClosure() -ParameterFilter { $EsxCli -eq $script:esxCli -and $EsxCliCommandMethod -eq $script:constants.EsxCliSetMethodInvoke -and $null -eq (Compare-Object -ReferenceObject $EsxCliCommandMethodArguments.Values -DifferenceObject $script:constants.EsxCliSetMethodArgs.Values) } -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenTheEsxCliCommandMethodIsExecutedSuccessfully {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli
    $esxCliSetMethodArgsMock = $script:constants.EsxCliSetMethodArgs

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliSetMethodArgsMock }.GetNewClosure() -ParameterFilter { $Command -eq $script:constants.EsxCliSetMethodCreateArgs } -Verifiable
    Mock -CommandName Invoke-EsxCliCommandMethod -MockWith { return $null }.GetNewClosure() -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileInvokingTheEsxCliCommandRetrievalMethod {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { throw }.GetNewClosure() -ParameterFilter { $Command -eq $script:constants.EsxCliGetMethodInvoke } -Verifiable

    $esxCliBaseDSCProperties
}

function New-MocksWhenTheEsxCliCommandRetrievalMethodIsExecutedSuccessfully {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $esxCliBaseDSCProperties = New-EsxCliDSCProperties

    $esxCliMock = $script:esxCli
    $esxCliGetMethodMock = $script:constants.DCUIKeyboardUSDefaultLayout

    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $V2 } -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliGetMethodMock }.GetNewClosure() -ParameterFilter { $Command -eq $script:constants.EsxCliGetMethodInvoke } -Verifiable

    $esxCliBaseDSCProperties
}

function Compare-Hashtables {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [hashtable]
        $HashtableOne,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [hashtable]
        $HashtableTwo
    )

    $result = $true
    if ($HashtableOne.Keys.Count -ne $HashtableTwo.Keys.Count) {
        $result = $false
    }
    else {
        $hashtableTwoKeys = $HashtableTwo.Keys
        foreach ($key in $HashtableOne.Keys) {
            if ($hashtableTwoKeys -NotContains $key) {
                $result = $false
                break
            }

            $hashtableOneValue = $HashtableOne.$key
            $hashtableTwoValue = $HashtableTwo.$key

            if ($hashtableOneValue -is [array] -and $hashtableTwoValue -is [array]) {
                $elementsToAdd = $hashtableOneValue | Where-Object -FilterScript { $hashtableTwoValue -NotContains $_ }
                $elementsToRemove = $hashtableTwoValue | Where-Object -FilterScript { $hashtableOneValue -NotContains $_ }

                if ($null -ne $elementsToAdd -or $null -ne $elementsToRemove) {
                    $result = $false
                    break
                }
            }
            elseif ($hashtableOneValue -is [hashtable] -and $hashtableTwoValue -is [hashtable]) {
                $areEqual = Compare-Hashtables -HashtableOne $hashtableOneValue -HashtableTwo $hashtableTwoValue
                if (!$areEqual) {
                    $result = $false
                    break
                }
            }
            else {
                if ($hashtableOneValue -ne $hashtableTwoValue) {
                    $result = $false
                    break
                }
            }
        }
    }

    return $result
}
