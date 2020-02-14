<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class EsxCliBaseDSC : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The PowerCLI EsxCli version 2 interface to ESXCLI.
    #>
    hidden [PSObject] $EsxCli

    <#
    .DESCRIPTION

    The EsxCli command for the DSC Resource that inherits the base class.
    For the DCUI Keyboard DSC Resource the command is the following: 'system.settings.keyboard.layout'.
    #>
    hidden [string] $EsxCliCommand

    <#
    .DESCRIPTION

    The name of the DSC Resource that inherits the base class.
    #>
    hidden [string] $DscResourceName = $this.GetType().Name

    hidden [string] $EsxCliAddMethodName = 'add'
    hidden [string] $EsxCliSetMethodName = 'set'
    hidden [string] $EsxCliRemoveMethodName = 'remove'
    hidden [string] $EsxCliGetMethodName = 'get'
    hidden [string] $EsxCliListMethodName = 'list'

    hidden [string] $CouldNotRetrieveEsxCliInterfaceMessage = "Could not retrieve EsxCli interface for VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotCreateMethodArgumentsMessage = "Could not create arguments for {0} method. For more information: {1}"
    hidden [string] $EsxCliCommandFailedMessage = "EsxCli command {0} failed to execute successfully. For more information: {1}"

    <#
    .DESCRIPTION

    Retrieves the EsxCli version 2 interface to ESXCLI for the specified VMHost.
    #>
    [void] GetEsxCli($vmHost) {
        try {
            $this.EsxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2 -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRetrieveEsxCliInterfaceMessage -f $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Executes the specified method for modification - 'set', 'add' or 'remove' of the specified EsxCli command.
    #>
    [void] ExecuteEsxCliModifyMethod($methodName, $methodArguments) {
        $esxCliCommandMethod = "$($this.EsxCliCommand).$methodName."
        $esxCliMethodArgs = $null

        try {
            $esxCliMethodArgs = Invoke-Expression -Command ("`$this.EsxCli." + $esxCliCommandMethod + 'CreateArgs()') -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateMethodArgumentsMessage -f $methodName, $_.Exception.Message)
        }

        # Skips the properties that are defined in the base classes of the Dsc Resource because they are not arguments of the EsxCli command.
        $dscResourceNamesOfProperties = $this.GetType().GetProperties() |
                                        Where-Object -FilterScript { $_.DeclaringType.Name -eq $this.DscResourceName } |
                                        Select-Object -ExpandProperty Name

        # A separate array of keys is needed because collections cannot be modified while being enumerated.
        $commandArgs = @()
        $commandArgs = $commandArgs + $esxCliMethodArgs.Keys
        foreach ($key in $commandArgs) {
            # The argument of the method is present in the method arguments hashtable and should be used instead of the property of the Dsc Resource.
            if ($methodArguments.Count -gt 0 -and $null -ne $methodArguments.$key) {
                $esxCliMethodArgs.$key = $methodArguments.$key
            }
            else {
                # The name of the property of the Dsc Resource starts with a capital letter whereas the key of the argument contains only lower case letters.
                $dscResourcePropertyName = $dscResourceNamesOfProperties | Where-Object -FilterScript { $_.ToLower() -eq $key.ToLower() }

                # Not all properties of the Dsc Resource are part of the arguments hashtable.
                if ($null -ne $dscResourcePropertyName) {
                    if ($this.$dscResourcePropertyName -is [string]) {
                        if (![string]::IsNullOrEmpty($this.$dscResourcePropertyName)) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                    elseif ($this.$dscResourcePropertyName -is [array]) {
                        if ($null -ne $this.$dscResourcePropertyName -and $this.$dscResourcePropertyName.Length -gt 0) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                    else {
                        if ($null -ne $this.$dscResourcePropertyName) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                }
            }
        }

        try {
            Invoke-EsxCliCommandMethod -EsxCli $this.EsxCli -EsxCliCommandMethod ($esxCliCommandMethod + 'Invoke({0})') -EsxCliCommandMethodArguments $esxCliMethodArgs
        }
        catch {
            throw ($this.EsxCliCommandFailedMessage -f ('esxcli.' + $this.EsxCliCommand), $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Executes the specified method for modification - 'set', 'add' or 'remove' of the specified EsxCli command.
    #>
    [void] ExecuteEsxCliModifyMethod($methodName) {
        $this.ExecuteEsxCliModifyMethod($methodName, @{})
    }

    <#
    .DESCRIPTION

    Executes the specified retrieval method - 'get' or 'list' of the specified EsxCli command.
    #>
    [PSObject] ExecuteEsxCliRetrievalMethod($methodName) {
        $esxCliCommandMethod = '$this.EsxCli.' + "$($this.EsxCliCommand).$methodName."

        try {
            $esxCliCommandMethodResult = Invoke-Expression -Command ($esxCliCommandMethod + 'Invoke()') -ErrorAction Stop -Verbose:$false
            return $esxCliCommandMethodResult
        }
        catch {
            throw ($this.EsxCliCommandFailedMessage -f ('esxcli.' + $this.EsxCliCommand), $_.Exception.Message)
        }
    }
}
