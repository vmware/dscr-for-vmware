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
.SYNOPSIS
Creates a new Resource Block for the specified Resource with the specified properties.

.DESCRIPTION
Creates a new Resource Block for the specified Resource with the specified properties. The Resource
Block is part of a Configuration. The function allows to dynamically pass Resource properties to the
Resource Block based on some criteria, which is not possible if the Resource Block is directly defined
in the Configuration.
Example function output:
Param(
    [Parameter(Mandatory = $true)]
    [hashtable]
    $Parameters
)

VMHostVssPortGroup VMHostVssPortGroup {
    VssName = $Parameters['VssName']
    VMHostName = $Parameters['VMHostName']
    Server = $Parameters['Server']
    Credential = $Parameters['Credential']
    Name = $Parameters['Name']
    Ensure = $Parameters['Ensure']
}

.PARAMETER ResourceName
Specifies the name of the Resource.

.PARAMETER Properties
Specifies the properties that are going to be populated for the specified Resource.
#>
function New-DscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $Properties
    )

    $stringBuilder = [System.Text.StringBuilder]::new()

    $stringBuilder.AppendLine("Param(")
    $stringBuilder.AppendLine("    [Parameter(Mandatory = `$true)]")
    $stringBuilder.AppendLine("    [hashtable]")
    $stringBuilder.AppendLine("    `$Parameters")
    $stringBuilder.AppendLine(")")

    $stringBuilder.Append([System.Environment]::NewLine)
    $stringBuilder.AppendLine("$ResourceName $ResourceName {")

    foreach($propertyName in $Properties.Keys) {
        $stringBuilder.AppendLine("    $propertyName = `$Parameters['$propertyName']")
    }

    $stringBuilder.AppendLine("}")

    [ScriptBlock]::Create($stringBuilder.ToString()).Invoke($Properties)
}

<#
.SYNOPSIS
Pushes the specified properties that are not $null to the properties hashtable.

.DESCRIPTION
Pushes the specified properties that are not $null to the properties hashtable. $null properties are not pushed
to the properties hashtable, because when the Configuration is parsed, the compiled MOF contains all $null properties
with their default values depending on the type, instead of ignoring them and them not being part of the compiled MOF file.

.PARAMETER ResourceBlockProperties
Specifies the hashtable with the properties that are going to be passed to the Resource Block.

.PARAMETER NullableProperties
Specifies the nullable properties that are going to be pushed to the properties hashtable. Only properties with value that is
different from $null are going to be pushed to the properties hashtable.
#>
function Push-NullablePropertiesToDscResourceBlock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [hashtable]
        $ResourceBlockProperties,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $NullableProperties
    )

    foreach ($nullablePropertyName in $NullableProperties.Keys) {
        if ($null -ne $NullableProperties.$nullablePropertyName) {
            $ResourceBlockProperties.$nullablePropertyName = $NullableProperties.$nullablePropertyName
        }
    }
}
