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

Configuration Test {
    Import-DscResource -ModuleName MyDscResource

    FileResource file1 
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
        DependsOn = '[FileResource]file3'
    }

    FileResource file2
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
    }

    FileResource file3 
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
        DependsOn = '[FileResource]file2'
    }

    FileResource file4
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
    }

    FileResource file5
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
    }

    FileResource file6
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
        DependsOn = '[FileResource]file7'
    }

    FileResource file7
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
        DependsOn = '[FileResource]file8'
    }

    FileResource file8
    {
        Path = "path"
        SourcePath = "path"
        Ensure = "present"
    }
}

# file2 -> file3 -> file1 -> file4 -> file5 -> file8 -> file7 -> file6
$Script:expectedCompiled = [VmwDscConfiguration]::new(
    'Test',
    @(
        [VmwDscResource]::new(
            'file2',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file3',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file1',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file4',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file5',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file8',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file7',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
        [VmwDscResource]::new(
            'file6',
            'FileResource',
            'MyDscResource',
            @{ 
                Path = "path"
                SourcePath = "path"
                Ensure = "present"
            }
        )
    )
)

