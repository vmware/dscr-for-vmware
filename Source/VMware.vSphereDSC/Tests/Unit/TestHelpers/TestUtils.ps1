<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function Import-VMwareVSphereDSCModule {
    <#
    .SYNOPSIS

    Imports the VMware.vSphereDSC module into the current session.

    .DESCRIPTION

    Imports the VMware.vSphereDSC module into the current session. Due to the fact that the module
    contains PowerShell classes and that the 'Using module' statement works only with strings and
    'ModuleSpecification' hashtables and can't include variables, the statement is wrapped in a Script
    Block to allow the path to the psm1 file to be passed as a variable.
    #>

    $modulePath = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).ModuleBase
    $moduleFilePath = Join-Path -Path $modulePath -ChildPath 'VMware.vSphereDSC.psm1'

    $scriptBody = "Using module '$moduleFilePath'"
    $script = [ScriptBlock]::Create($scriptBody)
    . $script
}

function Invoke-TestSetup {
    [CmdletBinding()]

    $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $mockModuleLocation = "$unitTestsFolder\TestHelpers"

    $env:PSModulePath = $mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
}

function Invoke-TestCleanup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $ModulePath
    )

    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $ModulePath
}
