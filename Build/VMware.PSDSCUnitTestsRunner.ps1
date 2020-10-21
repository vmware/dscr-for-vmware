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
.Notes
The Unit tests for VMware.PSDesiredStateConfiguration get executed in a Ubuntu 18.04 build because
they depend on PowerShell 7.0.
#>

# add common utilities
. (Join-Path $PSScriptRoot 'common.ps1')

# add required DSC Resource for unit tests
$moduleName = 'VMware.PSDesiredStateConfiguration'
$moduleRoot = Join-Path $Script:SourceRoot $moduleName
$configPath = Join-Path (Join-Path (Join-Path $moduleRoot 'Tests') 'Required Dsc Resources') 'MyDscResource'
$env:PSModulePath += "$([System.IO.Path]::PathSeparator)$configPath"

# run unit tests
$coveragePercent = Invoke-UnitTests $moduleName

# save result in shared travis workspace file
$resultPath = Join-Path $env:TRAVIS_BUILD_DIR $env:PSDS_CODECOVERAGE_RESULTFILE
$coveragePercent | Out-File $resultPath
