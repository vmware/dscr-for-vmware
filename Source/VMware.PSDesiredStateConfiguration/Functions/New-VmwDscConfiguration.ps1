<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VmwDscConfiguration {
    <#
    .SYNOPSIS
        Compiles a DSC Configuration into a VmwDscConfiguration object, which contains
        the name of the DSC Configuration and the DSC Resources defined in it.

    .DESCRIPTION
        Compiles a DSC Configuration into a VmwDscConfiguration object, which contains
        the name of the DSC Configuration and the DSC Resources defined in it. The provided
        PowerShell script file can contain multiple DSC Configurations in which case the cmdlet
        returns an array of VmwDscConfiguration objects. If the ConfigurationName parameter is specified,
        the cmdlet returns only one VmwDscConfiguration object - the one constructed from the specified
        DSC Configuration.

    .PARAMETER Path
        Specifies a file path of a file that contains DSC Configurations. The file can contain multiple DSC Configurations
        and for each one, a separate VmwDscConfiguration object is created. If ConfigurationData hashtable is defined in the provided
        file, it is passed to each DSC Configuration defined in the file.

    .PARAMETER ConfigurationName
        Specifies the name of the DSC Configuration which should be compiled into a VmwDscConfiguration object. This parameter is applicable
        only when multiple DSC Configurations are defined in the file and only one specific DSC Configuration should be compiled. If not specified,
        all DSC Configurations in the file are compiled and returned as VmwDscConfiguration objects.

    .PARAMETER Parameters
        Specifies the parameters of the file that contains the DSC Configurations as a hashtable
        where each key is the parameter name and each value is the parameter value.

    .EXAMPLE
        Compiles the DSC Configurations defined in the vSphere_Config file located in the current directory.

        PS> $dscConfigs = New-VmwDscConfiguration -Path .\vSphere_Config.ps1

    .EXAMPLE
        Compiles the DSC Configuration vSphereNode_Config defined in the vSphere_Config file located in the current directory
        and passes the VMHostName parameter to the vSphere_Config file.

        PS> $dscConfig = New-VmwDscConfiguration -Path .\vSphere_Config.ps1 -ConfigurationName 'vSphereNode_Config' -Parameters @{ VMHostName = 'MyVMHost' }

    #>
    [CmdletBinding()]
    [OutputType([VmwDscConfiguration[]])]
    Param (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [string]
        $ConfigurationName,

        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]
        $Parameters
    )

    $vmwDscConfigurations = @()

    try {
        $savedVerbosePreference = $Global:VerbosePreference
        $Global:VerbosePreference = $VerbosePreference

        $dscConfigurationFileParser = [DscConfigurationFileParser]::new()
        $dscConfigurationBlocks = $dscConfigurationFileParser.ParseDscConfigurationFile($Path, $Parameters)

        foreach ($dscConfigurationBlock in $dscConfigurationBlocks) {
            if (![string]::IsNullOrEmpty($ConfigurationName) -and $dscConfigurationBlock.Name -ne $ConfigurationName) {
                continue
            }

            $dscConfigurationCompiler = [DscConfigurationCompiler]::new($dscConfigurationBlock.Name, $Parameters, $dscConfigurationBlock.ConfigurationData)
            $vmwDscConfiguration = $dscConfigurationCompiler.CompileDscConfiguration($dscConfigurationBlock)

            $vmwDscConfigurations += $vmwDscConfiguration
        }
    }
    finally {
        $Global:VerbosePreference = $savedVerbosePreference
    }

    $vmwDscConfigurations
}
