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

Class that resolves the dependencies between the classes in the VMware.PSDesiredStateConfiguration
module - the order of importing each class when the module is loaded.
#>
class ClassResolver {
    [System.IO.FileInfo[]] $ClassFiles

    ClassResolver([System.IO.FileInfo[]] $classFiles) {
        $this.ClassFiles = $classFiles
    }

    <#
    .DESCRIPTION

    Orders the specified class files depending on the other classes that they depend on. A dependency of a class
    can be inheriting another class, property or method type or method argument. Each dependency class is added
    before the class that depends on it.
    #>
    [System.IO.FileInfo[]] OrderClassFiles() {
        $orderedFiles = @()
        $resolvedClasses = New-Object System.Collections.Generic.List[ClassNode]

        $classNodes = $this.AddDependenciesBetweenClasses()

        foreach ($classNode in $classNodes) {
            $this.GetOrderedClasses($classNode, ([ref] $resolvedClasses))
        }

        foreach ($class in $resolvedClasses) {
            $containedFile = $orderedFiles | Where-Object -FilterScript { $_.Name -eq $class.FileName }
            if ($null -eq $containedFile) {
                $file = $this.ClassFiles | Where-Object -FilterScript { $_.Name -eq $class.FileName }
                $orderedFiles += $file
            }
        }

        return $orderedFiles
    }

    hidden [ClassNode[]] AddDependenciesBetweenClasses() {
        $classNodes = @()
        $classNames = $this.ClassFiles.BaseName

        foreach ($file in $this.ClassFiles) {
            $classNode = [ClassNode]::new()
            $classNode.Name = $file.BaseName
            $classNode.FileName = $file.Name

            $classContentRaw = Get-Content -Path $file.FullName -Raw
            $tokens = [System.Management.Automation.PSParser]::Tokenize($classContentRaw, [ref]$null)

            $typesUsedInClass = $tokens | Where-Object -FilterScript { $_.Type -eq 'Type' }
            foreach ($type in $typesUsedInClass) {
                <#
                    When the class is a property or method type or array of the specified type,
                    the brackets '[' and ']' must be removed to retrieve the correct type.
                #>
                $typeName = $null
                if ($type.Content -Match '\[') {
                    $splittedTypeContent = $type.Content.Split('[').Split(']')
                    $typeName = $splittedTypeContent[1]
                }
                else {
                    $typeName = $type.Content
                }

                if ($typeName -ne $classNode.Name) {
                    if ($classNames -Contains $typeName -and $classNode.Dependencies -NotContains $typeName) {
                        $classNode.AddDependency($typeName)
                    }
                }
            }

            $classNodes += $classNode
        }

        foreach ($classNode in $classNodes) {
            foreach ($classNodeDependency in $classNode.Dependencies) {
                $edge = $classNodes | Where-Object -FilterScript { $_.Name -eq $classNodeDependency }
                $classNode.AddEdge($edge)
            }
        }

        return $classNodes
    }

    hidden [void] GetOrderedClasses([ClassNode] $classNode, [ref] $resolvedClasses) {
        foreach ($edge in $classNode.Edge) {
            $containedEdge = $resolvedClasses.Value | Where-Object -FilterScript { $_.Name -eq $edge.Name }
            if ($null -eq $containedEdge) {
                $this.GetOrderedClasses($edge, ([ref] $resolvedClasses.Value))
            }
        }

        $containedClassNode = $resolvedClasses.Value | Where-Object -FilterScript { $_.Name -eq $classNode.Name }
        if ($null -eq $containedClassNode) {
            $resolvedClasses.Value.Add($classNode)
        }
    }
}
