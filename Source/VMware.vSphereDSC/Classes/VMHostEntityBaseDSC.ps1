<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostEntityBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the VMHost which is going to be used.
    #>
    [DscProperty(Key)]
    [string] $VMHostName

    <#
    .DESCRIPTION

    The VMHost which is going to be used.
    #>
    hidden [PSObject] $VMHost

    hidden [string] $RetrieveVMHostMessage = "Retrieving VMHost {0} from vCenter {1}."
    hidden [string] $CouldNotRetrieveVMHostMessage = "Could not retrieve VMHost {0} from vCenter {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the VMHost with the specified name from the server.
    If the VMHost is not found, it throws an exception.
    #>
    [void] RetrieveVMHost() {
        try {
            Write-VerboseLog -Message $this.RetrieveVMHostMessage -Arguments @($this.VMHostName, $this.Connection.Name)
            $getVMHostParams = @{
                Server = $this.Connection
                Name = $this.VMHostName
                ErrorAction = 'Stop'
                Verbose = $false
            }
            $this.VMHost = Get-VMHost @getVMHostParams
        }
        catch {
            throw ($this.CouldNotRetrieveVMHostMessage -f $this.VMHostName, $this.Connection.Name, $_.Exception.Message)
        }
    }
}
