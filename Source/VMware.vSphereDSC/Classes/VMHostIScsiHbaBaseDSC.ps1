<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostIScsiHbaBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the type of the CHAP (Challenge Handshake Authentication Protocol).
    #>
    [DscProperty()]
    [ChapType] $ChapType = [ChapType]::Unset

    <#
    .DESCRIPTION

    Specifies the CHAP authentication name.
    #>
    [DscProperty()]
    [string] $ChapName

    <#
    .DESCRIPTION

    Specifies the CHAP authentication password.
    #>
    [DscProperty()]
    [string] $ChapPassword

    <#
    .DESCRIPTION

    Indicates that Mutual CHAP is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $MutualChapEnabled

    <#
    .DESCRIPTION

    Specifies the Mutual CHAP authentication name.
    #>
    [DscProperty()]
    [string] $MutualChapName

    <#
    .DESCRIPTION

    Specifies the Mutual CHAP authentication password.
    #>
    [DscProperty()]
    [string] $MutualChapPassword

    <#
    .DESCRIPTION

    Specifies whether to change the password for CHAP, Mutual CHAP or both. When the property is not specified or its value is $false, it is ignored.
    If the property is $true the passwords for CHAP and Mutual CHAP are changed to their desired values.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $IScsiDeviceType = 'iSCSI'

    hidden [string] $CouldNotRetrieveIScsiHbaMessage = "Could not retrieve iSCSI Host Bus Adapter {0} from VMHost {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the iSCSI Host Bus Adapter with the specified name from the specified VMHost if it exists.
    #>
    [PSObject] GetIScsiHba($iScsiHbaName) {
        try {
            $iScsiHba = Get-VMHostHba -Server $this.Connection -VMHost $this.VMHost -Device $iScsiHbaName -Type $this.IScsiDeviceType -ErrorAction Stop -Verbose:$false
            return $iScsiHba
        }
        catch {
            throw ($this.CouldNotRetrieveIScsiHbaMessage -f $iScsiHbaName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Checks if the CHAP settings should be modified based on the current authentication properties.
    #>
    [bool] ShouldModifyCHAPSettings($authenticationProperties, $inheritChap, $inheritMutualChap) {
        $shouldModifyCHAPSettings = @()

        $shouldModifyCHAPSettings += ($null -ne $inheritChap -and $inheritChap -ne $authenticationProperties.ChapInherited)
        $shouldModifyCHAPSettings += ($this.ChapType -ne [ChapType]::Unset -and $this.ChapType.ToString() -ne $authenticationProperties.ChapType.ToString())
        $shouldModifyCHAPSettings += ($null -ne $inheritMutualChap -and $inheritMutualChap -ne $authenticationProperties.MutualChapInherited)
        $shouldModifyCHAPSettings += ($null -ne $this.MutualChapEnabled -and $this.MutualChapEnabled -ne $authenticationProperties.MutualChapEnabled)

        # Force should determine the Desired State only when it is $true.
        $shouldModifyCHAPSettings += ($null -ne $this.Force -and $this.Force)

        # CHAP and Mutual CHAP names should be ignored when determining the Desired State when CHAP type is 'Prohibited'.
        if ($this.ChapType -ne [ChapType]::Prohibited) {
            $shouldModifyCHAPSettings += (![string]::IsNullOrEmpty($this.ChapName) -and $this.ChapName -ne [string] $authenticationProperties.ChapName)
            $shouldModifyCHAPSettings += (![string]::IsNullOrEmpty($this.MutualChapName) -and $this.MutualChapName -ne [string] $authenticationProperties.MutualChapName)
        }

        return ($shouldModifyCHAPSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Checks if the CHAP settings should be modified based on the current authentication properties.
    #>
    [bool] ShouldModifyCHAPSettings($authenticationProperties) {
        return $this.ShouldModifyCHAPSettings($authenticationProperties, $null, $null)
    }

    <#
    .DESCRIPTION

    Populates the cmdlet parameters with the CHAP settings based on the following criteria:
    1. CHAP settings can only be passed to the cmdlet if the 'InheritChap' option is not passed or it is passed with a '$false' value.
    2. Mutual CHAP settings can only be passed to the cmdlet if the 'InheritMutualChap' option is not passed or it is passed with a '$false' value.
    3. CHAP name and CHAP password can be passed to the cmdlet if the CHAP type is not 'Prohibited'.
    4. Mutual CHAP settings can only be passed to the cmdlet if the CHAP type is 'Required'.
    5. Mutual CHAP name and Mutual CHAP password can be passed to the cmdlet if Mutual CHAP enabled is not passed
       or if it is passed with a '$true' value.
    #>
    [void] PopulateCmdletParametersWithCHAPSettings($cmdletParams, $inheritChap, $inheritMutualChap) {
        if ($null -ne $inheritChap -and $inheritChap) {
            $cmdletParams.InheritChap = $inheritChap
        }
        else {
            # When 'InheritChap' is $false, it can be passed to the cmdlet only if CHAP type is not 'Prohibited'.
            if ($null -ne $inheritChap -and $this.ChapType -ne [ChapType]::Prohibited) { $cmdletParams.InheritChap = $inheritChap }
            if ($this.ChapType -ne [ChapType]::Unset) { $cmdletParams.ChapType = $this.ChapType.ToString() }

            if ($this.ChapType -ne [ChapType]::Prohibited) {
                if (![string]::IsNullOrEmpty($this.ChapName)) { $cmdletParams.ChapName = $this.ChapName }
                if (![string]::IsNullOrEmpty($this.ChapPassword)) { $cmdletParams.ChapPassword = $this.ChapPassword }
            }
        }

        if ($null -ne $inheritMutualChap -and $inheritMutualChap) {
            $cmdletParams.InheritMutualChap = $inheritMutualChap
        }
        else {
            # When 'InheritMutualChap' is $false, it can be passed to the cmdlet only if CHAP type is not 'Prohibited'.
            if ($null -ne $inheritMutualChap -and $this.ChapType -ne [ChapType]::Prohibited) { $cmdletParams.InheritMutualChap = $inheritMutualChap }

            if ($this.ChapType -eq [ChapType]::Required) {
                if ($null -ne $this.MutualChapEnabled) { $cmdletParams.MutualChapEnabled = $this.MutualChapEnabled }

                if ($null -eq $this.MutualChapEnabled -or $this.MutualChapEnabled) {
                    if (![string]::IsNullOrEmpty($this.MutualChapName)) { $cmdletParams.MutualChapName = $this.MutualChapName }
                    if (![string]::IsNullOrEmpty($this.MutualChapPassword)) { $cmdletParams.MutualChapPassword = $this.MutualChapPassword }
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the cmdlet parameters with the CHAP settings.
    #>
    [void] PopulateCmdletParametersWithCHAPSettings($cmdletParams) {
        $this.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $null, $null)
    }
}
