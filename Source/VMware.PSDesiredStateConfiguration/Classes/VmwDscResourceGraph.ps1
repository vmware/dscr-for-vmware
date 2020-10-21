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
This graph is used to sort Resources by their 'DependsOn' key in the 'Property' property
#>
class VmwDscResourceGraph {
    [System.Collections.Specialized.OrderedDictionary] 
    hidden $Edges

    [System.Collections.Specialized.OrderedDictionary]
    hidden $Resources

    VmwDscResourceGraph([System.Collections.Specialized.OrderedDictionary] $Resources) {
        $this.Resources = $Resources
        $this.FillEdges()
    }

    <#
    .Description
    Sorts the resources in the graph so that
    the resources get ordered based on their dependencies
    #>
    [System.Array] TopologicalSort() {
        # bool array for keeping track of visited resources
        $visited = New-Object 'System.Collections.Generic.HashSet[string]'
        # hashtable for detecting circular dependencies
        $cycles = New-Object 'System.Collections.Generic.HashSet[string]'
        # resource keys wil be kept inside this stack
        $sortedResourceKeys = New-Object -TypeName 'System.Collections.Stack'

        $keysArr = @($this.Edges.Keys)

        for ($i = 0; $i -lt $keysArr.Count; $i++) {
            $ind = $this.edges.Count - 1 - $i
            $key = $keysArr[$ind]
            $this.TopologicalSortUtil($key, $sortedResourceKeys, $visited, $cycles)
        }

        $result = New-Object -TypeName 'System.Collections.Arraylist'

        foreach ($resKey in $sortedResourceKeys) {
            $result.Add($this.Resources[$resKey]) | Out-Null
        }

        return $result.ToArray()
    }

    <#
    .Description
    Uses DFS in order to traverse the graph
    #>
    [void] hidden TopologicalSortUtil(
    [string] $ResKey,
    [System.Collections.Stack] $sortedResourceKeys,
    [System.Collections.Generic.HashSet[string]] $Visited,
    [System.Collections.Generic.HashSet[string]] $Cycles) {
        if ($Cycles.Contains($ResKey)) {
            throw "Cycle detected with key: $ResKey"
        }
    
        if ($Visited.Contains($ResKey)) {
            return
        }
    
        $Visited.Add($ResKey) | Out-Null
        $Cycles.Add($ResKey) | Out-Null 
    
        foreach ($child in $this.Edges[$ResKey]) {
            $this.TopologicalSortUtil($child, $sortedResourceKeys, $visited, $cycles)
        }
    
        $Cycles.Remove($ResKey) | Out-Null
        $SortedResourceKeys.Push($ResKey) | Out-Null
    }

    <#
    .Description
    Fills $Edges ordered dictionary from $Resources ordered dictionary
    #>
    [void] hidden FillEdges() {
        # adjecency list representing dependencies between resources
        $this.Edges = [ordered]@{}

        # initialize lists
        foreach ($key in $this.Resources.Keys) {
            $children = New-Object -TypeName 'System.Collections.ArrayList'
            $this.Edges[$key] = $children
        }

        # insert dependencies into edges
        foreach ($key in $this.Resources.Keys) {
            if (-not $this.Resources[$key].Property.ContainsKey('DependsOn')) {
                continue
            }

            $dependencies = $this.Resources[$key].Property['DependsOn']

            foreach ($dependency in $dependencies) {
                if (-not $this.Edges.Contains($dependency)) {
                    throw ($Script:DependsOnResourceNotFoundException -f $this.Resources[$key].InstanceName, $dependency)
                }
        
                # remove DependsOn item so that it does not conflict with Invoke-DscResource later on
                $this.Resources[$key].Property.Remove('DependsOn') | Out-Null
        
                $this.Edges[$dependency].Add($key) | Out-Null
            }
        }
    }
}

