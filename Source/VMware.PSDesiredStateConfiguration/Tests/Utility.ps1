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
Performs an assert on two [VmwDscResource] objects to check if they're equal
#>
function Script:AssertResourceEqual {
    Param (
        [VmwDscResource]
        $ResultRes,

        [VmwDscResource]
        $ExpectedRes
    )
    
    # assert regular properties
    $ResultRes.InstanceName | Should -Be $ExpectedRes.InstanceName
    $ResultRes.ResourceType | Should -Be $ExpectedRes.ResourceType

    ($null -ne $ResultRes.ModuleName) | Should -Be ($null -ne $ExpectedRes.ModuleName)

    if ($null -ne $ResultRes.ModuleName) {
        $ResultRes.ModuleName.Name | Should -Be $ExpectedRes.ModuleName.Name
        $ResultRes.ModuleName.RequiredVersion.ToString() | Should -Be $ExpectedRes.ModuleName.RequiredVersion.ToString()
    }

    $ResultRes.Property.Keys.Count | Should -Be $ExpectedRes.Property.Keys.Count

    # assert key value pairs in 'Property' property are equal
    foreach ($key in $ResultRes.Property.Keys) {
        $ResultResPropVal = $ResultRes.Property[$key]

        $isKeyContained = $ExpectedRes.Property.ContainsKey($key)
        $isKeyContained | Should -Be $true

        $ResultResPropVal | Should -Be $ExpectedRes.Property[$key]
    }

    $ResultRes.GetIsComposite() | Should -Be $ExpectedRes.GetIsComposite()

    if ($ResultRes.GetIsComposite()) {
        $ResultResInnerRes = $ResultRes.GetInnerResources()
        $ExpectedResInnerRes = $ExpectedRes.GetInnerResources()

        $ResultResInnerRes.Count | Should -Be $ExpectedResInnerRes.Count

        for ($j = 0; $j -lt $ResultResInnerRes.Count; $j++) {
            # assert inner Resources equal
            Script:AssertResourceEqual $ResultResInnerRes[$j] $ExpectedResInnerRes[$j]
        }
    } else {
        $ResultRes.GetInnerResources() | Should -Be $null
    }
}

<#
.DESCRIPTION
Performs an assert on two [VmwNode] objects to check if they're equal
#> 
function Script:AssertNodeEqual {
    Param (
        [VmwDscNode]
        $ResultNode,

        [VmwDscNode]
        $ExpectedNode
    )

    $ResultNode.InstanceName | Should -Be $ExpectedNode.InstanceName

    $ResultNode.Resources.Count | Should -Be $ExpectedNode.Resources.Count

    for ($i = 0; $i -lt $ResultNode.Resources.Count; $i++) {
        # assert resources array of node
        Script:AssertResourceEqual $ResultNode.Resources[$i] $ExpectedNode.Resources[$i]
    }
}

<#
.DESCRIPTION
Performs an assert on two [VmwDscConfiguration] objects to check if they're equal
#> 
function Script:AssertConfigurationEqual {
    Param (
        [VmwDscConfiguration]
        $Result,

        [VmwDscConfiguration]
        $Expected
    )

    # assert regular properties
    $Result.InstanceName | Should -Be $Expected.InstanceName
    $Result.Nodes.Count | Should -Be $Expected.Nodes.Count

    for ($i = 0; $i -lt $Result.Nodes.Count; $i++) {
        # assert node array of configuration
        Script:AssertNodeEqual $Result.Nodes[$i] $Expected.Nodes[$i]
    }
}
