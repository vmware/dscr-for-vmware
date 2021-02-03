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

Class that defines a DSC Resource.
#>
class VmwDscResource : DscItem {
    [ValidateNotNullOrEmpty()]
    [string] $ResourceType

    [ValidateNotNull()]
    [Hashtable] $Property

    [Microsoft.PowerShell.Commands.ModuleSpecification] $ModuleName

    hidden [VmwDscResource[]] $InnerResources

    VmwDscResource($instanceName, $resourceType, $moduleName, $property, $innerResources) : base($instanceName) {
        $this.Init($resourceType, $moduleName, $property, $innerResources)
    }

    VmwDscResource($instanceName, $resourceType, $moduleName, $property) : base($instanceName) {
        $this.Init($resourceType, $moduleName, $property, $null)
    }

    VmwDscResource($instanceName, $resourceType, $moduleName) : base($instanceName) {
        $this.Init($resourceType, $moduleName, @{}, $null)
    }

    <#
    .DESCRIPTION

    Init function that sets the values of properties, because powershell does not support chaining constructors
    #>
    hidden [void] Init($resourceType, $moduleName, $property, $innerResources) {
        $this.ResourceType = $resourceType
        $this.Property = $property
        $this.innerResources = $innerResources

        if ($null -ne $moduleName) {
            $this.ModuleName = $moduleName -as [Microsoft.PowerShell.Commands.ModuleSpecification]
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean flag on whether the DSC Resource is composite.
    #>
    [bool] GetIsComposite() {
        return $null -ne $this.InnerResources
    }

    <#
    .DESCRIPTION

    Returns inner resources for composite DSC Resources.
    #>
    [VmwDscResource[]] GetInnerResources() {
        return $this.innerResources
    }

    <#
    .DESCRIPTION

    Sets inner resources for a composite DSC resource.
    #>
    [void] SetInnerResources([VmwDscResource[]] $innerResources) {
        if ($null -eq $innerResources) {
            throw '$innerResources must not be null!'
        }

        $this.innerResources = $innerResources
    }

    <#
    .DESCRIPTION

    Gets the unique id of the DSC Resource.
    #>
    [string] GetId() {
        return "[$($this.ResourceType)]$($this.InstanceName)"
    }

    [string] ToString() {
        return "$($this.ResourceType) $($this.InstanceName)"
    }
}
