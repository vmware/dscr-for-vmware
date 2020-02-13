<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION

Retrieves the state of the VMKernel dump partition of the VMHost before the execution of the Integration Tests.
#>
function Get-InitialVMHostVMKernelDumpPartitionState {
    [CmdletBinding()]
    [OutputType([string])]

    $vmHostVMKernelDumpPartitionState = @{}

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop -Verbose:$false
    $esxCli = Get-EsxCli -Server $viServer -VMHost $vmHost -V2 -ErrorAction Stop -Verbose:$false

    $vmHostVMKernelDumpPartition = $esxCli.system.coredump.partition.get.Invoke()

    <#
    The VMKernel dump partition settings can be in three states:
    1. Active and configured.
    2. Inactive but configured.
    3. Neither active nor configured
    #>
    if ($null -ne $vmHostVMKernelDumpPartition.Active -and $null -ne $vmHostVMKernelDumpPartition.Configured) {
        $vmHostVMKernelDumpPartitionState.Enable = $true
        $vmHostVMKernelDumpPartitionState.Partition = $vmHostVMKernelDumpPartition.Configured
    }
    elseif ($null -eq $vmHostVMKernelDumpPartitionState.Active -and $null -ne $vmHostVMKernelDumpPartition.Configured) {
        $vmHostVMKernelDumpPartitionState.Enable = $false
        $vmHostVMKernelDumpPartitionState.Partition = $vmHostVMKernelDumpPartition.Configured
    }
    else {
        $vmHostVMKernelDumpPartitionState.Enable = $false
        $vmHostVMKernelDumpPartitionState.Partition = $null
        $vmHostVMKernelDumpPartitionState.Unconfigure = $true
    }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false

    $vmHostVMKernelDumpPartitionState
}

<#
.DESCRIPTION

Restores the initial state of the VMKernel dump partition of the VMHost.
#>
function Restore-VMHostVMKernelDumpPartitionToInitialState {
    [CmdletBinding()]

    $initialVMKernelDumpPartitionState = $script:configurationData.AllNodes.InitialVMKernelDumpPartitionState

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop -Verbose:$false
    $esxCli = Get-EsxCli -Server $viServer -VMHost $vmHost -V2 -ErrorAction Stop -Verbose:$false
    $coreDumpPartitionSetMethodArgs = $esxCli.system.coredump.partition.set.CreateArgs()

    if ($initialVMKernelDumpPartitionState.Enable) {
        $coreDumpPartitionSetMethodArgs.partition = $initialVMKernelDumpPartitionState.Partition

        try {
            $esxCli.system.coredump.partition.set.Invoke($coreDumpPartitionSetMethodArgs)
        }
        catch {
            throw 'Could not restore VMKernel dump partition initial state. For more information: {0}' -f $_.Exception.Message
        }
    }
    elseif ($null -ne $initialVMKernelDumpPartitionState.Partition) {
        $coreDumpPartitionSetMethodArgs.partition = $initialVMKernelDumpPartitionState.Partition

        try {
            $esxCli.system.coredump.partition.set.Invoke($coreDumpPartitionSetMethodArgs)
        }
        catch {
            throw 'Could not restore VMKernel dump partition initial state. For more information: {0}' -f $_.Exception.Message
        }

        # The partition is currently active and configured and needs to be made inactive.
        $coreDumpPartitionSetMethodArgs = $esxCli.system.coredump.partition.set.CreateArgs()
        $coreDumpPartitionSetMethodArgs = $initialVMKernelDumpPartitionState.Enable

        try {
            $esxCli.system.coredump.partition.set.Invoke($coreDumpPartitionSetMethodArgs)
        }
        catch {
            throw 'Could not restore VMKernel dump partition initial state. For more information: {0}' -f $_.Exception.Message
        }
    }
    else {
        $coreDumpPartitionSetMethodArgs.unconfigure = $initialVMKernelDumpPartitionState.Unconfigure

        try {
            $esxCli.system.coredump.partition.set.Invoke($coreDumpPartitionSetMethodArgs)
        }
        catch {
            throw 'Could not restore VMKernel dump partition initial state. For more information: {0}' -f $_.Exception.Message
        }
    }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false
}
