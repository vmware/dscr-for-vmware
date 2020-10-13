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
    Performs an assert on two [VmwDscResource] objects to check if they're equal
#>
function Script:AssertResourceEqual {
    param (
        [VmwDscResource]
        $resultRes,

        [VmwDscResource]
        $expectedRes
    )
    
    # assert regular properties
    $resultRes.InstanceName | Should -Be $expectedRes.InstanceName
    $resultRes.ModuleName | Should -Be $expectedRes.ModuleName
    $resultRes.ResourceType | Should -Be $expectedRes.ResourceType

    $resultRes.Property.Keys.Count | Should -Be $expectedRes.Property.Keys.Count

    # assert key value pairs in 'Property' property are equal
    foreach ($key in $resultRes.Property.Keys) {
        $resultResPropVal = $resultRes.Property[$key]

        $isKeyContained = $expectedRes.Property.ContainsKey($key)
        $isKeyContained | Should -Be $true

        $resultResPropVal | Should -Be $expectedRes.Property[$key]
    }

    $resultRes.GetIsComposite() | Should -Be $expectedRes.GetIsComposite()

    if ($resultRes.GetIsComposite()) {
        $resultResInnerRes = $resultRes.GetInnerResources()
        $expectedResInnerRes = $expectedRes.GetInnerResources()

        $resultResInnerRes.Count | Should -Be $expectedResInnerRes.Count

        for ($j = 0; $j -lt $resultResInnerRes.Count; $j++) {
            # assert inner Resources equal
            Script:AssertResourceEqual $resultResInnerRes[$j] $expectedResInnerRes[$j]
        }
    } else {
        $resultRes.GetInnerResources() | Should -Be $null
    }
}

<#
    .Description
    Performs an assert on two [VmwDscConfiguration] objects to check if they're equal
#> 
function Script:AssertConfigurationEqual {
    param (
        [VmwDscConfiguration]
        $result,

        [VmwDscConfiguration]
        $expected
    )

    # assert regular properties
    $result.InstanceName | Should -Be $expected.InstanceName
    $result.Resources.Count | Should -Be $expected.Resources.Count

    for ($i = 0; $i -lt $result.Resources.Count; $i++) {
        # assert resources array of configuration
        Script:AssertResourceEqual $result.Resources[$i] $expected.Resources[$i]
    }
}

