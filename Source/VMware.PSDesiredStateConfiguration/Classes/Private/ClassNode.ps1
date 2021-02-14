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

Class that defines each class in the VMware.PSDesiredStateConfiguration module as a
Node with Edges and Dependencies - other classes with which the class interacts.
#>
class ClassNode {
    [string] $Name

    [string] $FileName

    [string[]] $Dependencies

    [ClassNode[]] $Edge

    <#
    .DESCRIPTION

    Adds the specified dependency class name to the list of dependencies
    for the current ClassNode.
    #>
    [void] AddDependency([string] $dependency) {
        if ($null -eq $this.Dependencies) {
            $this.Dependencies = @()
        }

        $this.Dependencies += $dependency
    }

    <#
    .DESCRIPTION

    Adds the specified edge ClassNode to the list of edges
    for the current ClassNode.
    #>
    [void] AddEdge([ClassNode] $edge) {
        if ($null -eq $this.Edge) {
            $this.Edge = @()
        }

        $this.Edge += $edge
    }
}
