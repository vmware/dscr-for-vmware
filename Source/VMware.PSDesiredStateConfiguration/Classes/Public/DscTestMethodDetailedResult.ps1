<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION

Result type for Test-VmwDscConfiguration with -Detailed flag switched on.
#>
class DscTestMethodDetailedResult : BaseDscMethodResult {
    [bool] $InDesiredState

    [VmwDscResource[]] $ResourcesInDesiredState

    [VmwDscResource[]] $ResourcesNotInDesiredState

    DscTestMethodDetailedResult([VmwDscNode] $node, [PsObject[]] $stateArr) : base($node.InstanceName) {
        $this.NodeName = $node.InstanceName

        $this.GroupResourcesByDesiredState($node.Resources, $stateArr)
    }

    hidden [void] GroupResourcesByDesiredState([VmwDscResource[]] $resources, [PsObject[]] $stateArr) {
        $this.InDesiredState = $true
        $resInDesiredState = New-Object -TypeName 'System.Collections.ArrayList'
        $resNotInDesiredState = New-Object -TypeName 'System.Collections.ArrayList'

        for ($i = 0; $i -lt $resources.Count; $i++) {
            # states can be an array due to composite resources having multiple inner resources
            $states = $stateArr[$i]
            $currInDesiredState = $true

            foreach ($state in $states) {
                if (-not $state.InDesiredState) {
                    $currInDesiredState = $false
                    break
                }
            }

            # add to correct array depending on the desired state
            if ($currInDesiredState) {
                $resInDesiredState.Add($resources[$i]) | Out-Null
            } else {
                $resNotInDesiredState.Add($resources[$i]) | Out-Null
                $this.InDesiredState = $false
            }
        }

        $this.ResourcesInDesiredState = $resInDesiredState.ToArray()
        $this.ResourcesNotInDesiredState = $resNotInDesiredState.ToArray()
    }
}
