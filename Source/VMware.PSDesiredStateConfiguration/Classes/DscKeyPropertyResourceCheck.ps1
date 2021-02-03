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

Type used for checking uniqueness of a DSC Resource key properties.
#>
class DscKeyPropertyResourceCheck {
    [string] $DscResourceType

    # can contain only string, int, enum values, because only properties of those types can be keys
    [Hashtable] $KeyPropertiesToValues

    DscKeyPropertyResourceCheck([string] $dscResourceType, [Hashtable] $keyPropertiesToValues) {
        $this.DscResourceType = $dscResourceType
        $this.KeyPropertiesToValues = $keyPropertiesToValues
    }

    [bool] Equals([Object] $other) {
        $comparisonResult = $true
        $other = $other -as [DscKeyPropertyResourceCheck]

        if (-not $this.DscResourceType.Equals($other.DscResourceType)) {
            $comparisonResult = $false
        } else {
            foreach ($key in $this.KeyPropertiesToValues.Keys) {
                if ((-not $other.KeyPropertiesToValues.ContainsKey($key)) -or (-not $this.KeyPropertiesToValues[$key].Equals($other.KeyPropertiesToValues[$key]))) {
                    $comparisonResult = $false
                    break
                }
            }
        }

        return $comparisonResult
    }

    [int] GetHashCode() {
        $hash = $this.CalculateHashCode()

        return $hash
    }

    <#
    .DESCRIPTION
    Calculates the hashcode via the Get-KeyPropertyResourceCheckDotNetHashCode cmdlet, because
    it uses a custom c# type that is created during runtime and can't be used inside a class due to it
    raising a parse error.
    #>
    [int] CalculateHashCode() {
        $splat = @{
            ResourceType = $this.ResourceType
            KeyPropertiesToValues = $this.KeyPropertiesToValues
        }

        $hash = Get-KeyPropertyResourceCheckDotNetHashCode @splat

        return $hash
    }
}
