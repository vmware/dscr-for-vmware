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
.DESCRIPTION
Invokes the DSC Configuration with the 'Get' DSC method
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
        VmwDscNodes = $Configuration.Nodes
        Method = 'Get'
    }
    
    try {
        Invoke-VmwDscNodes @invokeParams
    } catch {
        $exceptionMessage = $_.Exception.ErrorRecord.ToString()
        
        if ($exceptionMessage -eq $Script:UserInputExitException) {
            return
        }
    }
}

<#
.DESCRIPTION
Invokes the DSC Configuration with the 'Set' DSC method
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
        VmwDscNodes = $Configuration.Nodes
        Method = 'Set'
    }
    
    try {
        Invoke-VmwDscNodes @invokeParams | Out-Null
    } catch {
        $exceptionMessage = $_.Exception.ErrorRecord.ToString()
        
        if ($exceptionMessage -eq $Script:UserInputExitException) {
            return
        }
    }
}

<#
.DESCRIPTION
Invokes the DSC Configuration with the 'Test' DSC method
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
        VmwDscNodes = $Configuration.Nodes
        Method = 'Test'
    }

    $resStateArr = $null
    
    try {
        $resStateArr = Invoke-VmwDscNodes @invokeParams
    } catch {
        $exceptionMessage = $_.Exception.ErrorRecord.ToString()
        
        if ($exceptionMessage -eq $Script:UserInputExitException) {
            return
        }
    }
     
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
.SYNOPSIS
Invoke dsc nodes.
#>
function Invoke-VmwDscNodes {
    Param(
        [VmwDscNode[]]
        $VmwDscNodes,

        [string]
        $Method
    )

    # check for vSphere node connections
    $validVsphereNodes = New-Object 'System.Collections.ArrayList'
    $vSphereNodes = $VmwDscNodes | Where-Object { $_ -is [VmwVsphereDscNode]}

    if ($null -ne $vSphereNodes) {
        $defaultViServers = GetDefaultViServers

        # check if any connections are established
        if ($null -eq $defaultViServers -or $defaultViServers.Count -eq 0) {
            throw $Script:NoVsphereConnectionsFoundException
        }

        $invalidNodeFound = $false

        foreach ($vSphereNode in $vSphereNodes) {
            $connection = $defaultViServers | Where-Object { $_.Name -eq $vSphereNode.InstanceName }

            $warningMessage = [string]::empty

            if ($null -eq $connection) {
                $warningMessage = ($Script:NoVsphereConnectionsFoundForNodeWarning -f $vSphereNode.InstanceName)
                
            } elseif ($connection.Count -gt 1) {
                $warningMessage = ($Script:TooManyConnectionOnASingleVCenterWarning -f $vSphereNode.InstanceName)
            } else {
                foreach ($resource in $vSphereNode.Resources) {
                    $resource.Property['Connection'] = $connection
                }

                $validVsphereNodes.Add($vSphereNode) | Out-Null
            }

            if (-not [string]::IsNullOrEmpty($warningMessage)) {
                Write-Warning $warningMessage
                $invalidNodeFound = $true
            }
        }

        if ($invalidNodeFound) {
            $title    = 'Invalid vSphere node(s) found'
            $question = 'Warnings for the invalid vSphere nodes have been displayed and those nodes will be ignored. Are you sure you want to proceed?'
            $choices  = @('&Yes', '&No')

            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

            if ($decision -ne 0) {
                throw $Script:UserInputExitException
            }
        }
    }

    $nodesToIterate = ($validVsphereNodes.ToArray()) + ($VmwDscNodes | Where-Object { $_.GetType() -eq [VmwDscNode] })

    foreach ($node in $nodesToIterate) {
        $jobSplatParams = @{
            ScriptBlock = (Get-Command Invoke-VmwDscResourceJob).ScriptBlock
            ArgumentList = @( $node.Resources, $Method )
        }

        $job = Start-ThreadJob @jobSplatParams

        
        Write-Debug ("Thread job with id: $($job.Id) on node: $($node.InstanceName) started.")
    }

    $jobResult = Get-Job | Wait-Job | Receive-Job

    $jobResult
}

<#
.DESCRIPTION
Retrieves the DefaultVIServers array global variable
#>
function GetDefaultViServers {
    $Global:DefaultVIServers
}

function Invoke-VmwDscResourceJob {
    Param(
        # [VmwDscResource[]]
        $DscResources,

        [string]
        $Method
    )

    $path = Join-Path -Path (Split-Path $Using:PSScriptRoot) -ChildPath 'VMware.PSDesiredStateConfiguration.psd1'

    Import-Module $path

    <#
    .DESCRIPTION
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
    .DESCRIPTION
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
        } else {
            # checks if the resource is in target state
            $isInDesiredState = Invoke-DscResource @invokeSplatParams -Method 'Test'

            # executes 'set' method only if state is not desired
            if ($isInDesiredState.InDesiredState) {
                $invokeResult = $isInDesiredState
            } else {
                $invokeResult = Invoke-DscResource @invokeSplatParams -Method $Method
            }
        }

        $invokeResult
    }

    $nodeInvokeResult = Invoke-VmwDscResources -DscResources $DscResources -Method $Method

    $nodeInvokeResult
}
