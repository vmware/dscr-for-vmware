<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostSatpClaimRule : EsxCliBaseDSC {
    <#
    .DESCRIPTION

    Value indicating if the SATP Claim Rule should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Name of the SATP Claim Rule.
    #>
    [DscProperty(Key)]
    [string] $RuleName

    <#
    .DESCRIPTION

    PSP options for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $PSPOptions

    <#
    .DESCRIPTION

    Transport Property of the Satp Claim Rule.
    #>
    [DscProperty()]
    [string] $Transport

    <#
    .DESCRIPTION

    Description string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Description

    <#
    .DESCRIPTION

    Vendor string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Vendor

    <#
    .DESCRIPTION

    System default rule added at boot time.
    #>
    [DscProperty()]
    [nullable[bool]] $Boot

    <#
    .DESCRIPTION

    Claim type for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Type

    <#
    .DESCRIPTION

    Device of the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Device

    <#
    .DESCRIPTION

    Driver string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Driver

    <#
    .DESCRIPTION

    Claim option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $ClaimOptions

    <#
    .DESCRIPTION

    Default PSP for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Psp

    <#
    .DESCRIPTION

    Option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Options

    <#
    .DESCRIPTION

    Model string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Model

    <#
    .DESCRIPTION

    Value, which ignores validity checks and install the rule anyway.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.GetEsxCli($vmHost)
            $satpClaimRule = $this.GetSatpClaimRule()
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            if ($this.Ensure -eq [Ensure]::Present) {
                if (!$satpClaimRulePresent) {
                    $this.AddSatpClaimRule()
                }
            }
            else {
                if ($satpClaimRulePresent) {
                    $this.RemoveSatpClaimRule()
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.GetEsxCli($vmHost)
            $satpClaimRule = $this.GetSatpClaimRule()
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = $satpClaimRulePresent
            }
            else {
                $result = -not $satpClaimRulePresent
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSatpClaimRule] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSatpClaimRule]::new()

            $result.Server = $this.Server
            $result.RuleName = $this.RuleName
            $result.Boot = $this.Boot
            $result.Type = $this.Type
            $result.Force = $this.Force

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $result.Name = $vmHost.Name

            $this.GetEsxCli($vmHost)
            $satpClaimRule = $this.GetSatpClaimRule()
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            if (!$satpClaimRulePresent) {
                $result.Ensure = "Absent"
                $result.Psp = $this.Psp
                $this.PopulateResult($result, $this)
            }
            else {
                $result.Ensure = "Present"
                $result.Psp = $satpClaimRule.DefaultPSP
                $this.PopulateResult($result, $satpClaimRule)
            }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired SATP Claim Rule is equal to the passed SATP Claim Rule.
    #>
    [bool] Equals($satpClaimRule) {
        if ($this.RuleName -ne $satpClaimRule.Name) {
            return $false
        }

        <#
            For every optional property we check if it is not passed(if it is null), because
            all properties on the server, which are not set are returned as empty strings and
            if we compare null with empty string the equality will fail.
        #>

        if ($null -ne $this.PSPOptions -and $this.PSPOptions -ne $satpClaimRule.PSPOptions) {
            return $false
        }

        if ($null -ne $this.Transport -and $this.Transport -ne $satpClaimRule.Transport) {
            return $false
        }

        if ($null -ne $this.Description -and $this.Description -ne $satpClaimRule.Description) {
            return $false
        }

        if ($null -ne $this.Vendor -and $this.Vendor -ne $satpClaimRule.Vendor) {
            return $false
        }

        if ($null -ne $this.Device -and $this.Device -ne $satpClaimRule.Device) {
            return $false
        }

        if ($null -ne $this.Driver -and $this.Driver -ne $satpClaimRule.Driver) {
            return $false
        }

        if ($null -ne $this.ClaimOptions -and $this.ClaimOptions -ne $satpClaimRule.ClaimOptions) {
            return $false
        }

        if ($null -ne $this.Psp -and $this.Psp -ne $satpClaimRule.DefaultPSP) {
            return $false
        }

        if ($null -ne $this.Options -and $this.Options -ne $satpClaimRule.Options) {
            return $false
        }

        if ($null -ne $this.Model -and $this.Model -ne $satpClaimRule.Model) {
            return $false
        }

        return $true
    }

    <#
    .DESCRIPTION

    Returns the desired SatpClaimRule if the Rule is present on the server, otherwise returns $null.
    #>
    [PSObject] GetSatpClaimRule() {
        $foundSatpClaimRule = $null
        $satpClaimRules = Get-SATPClaimRules -EsxCli $this.EsxCli

        foreach ($satpClaimRule in $satpClaimRules) {
            if ($this.Equals($satpClaimRule)) {
                $foundSatpClaimRule = $satpClaimRule
                break
            }
        }

        return $foundSatpClaimRule
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the SATP Claim Rule properties from the server.
    #>
    [void] PopulateResult($result, $satpClaimRule) {
        $result.PSPoptions = $satpClaimRule.PSPOptions
        $result.Transport = $satpClaimRule.Transport
        $result.Description = $satpClaimRule.Description
        $result.Vendor = $satpClaimRule.Vendor
        $result.Device = $satpClaimRule.Device
        $result.Driver = $satpClaimRule.Driver
        $result.ClaimOptions = $satpClaimRule.ClaimOptions
        $result.Options = $satpClaimRule.Options
        $result.Model = $satpClaimRule.Model
    }

    <#
    .DESCRIPTION

    Populates the arguments for the Add and Remove operations of SATP Claim Rule with the specified properties from the user.
    #>
    [void] PopulateSatpArgs($satpArgs) {
        $satpArgs.satp = $this.RuleName
        $satpArgs.pspoption = $this.PSPoptions
        $satpArgs.transport = $this.Transport
        $satpArgs.description = $this.Description
        $satpArgs.vendor = $this.Vendor
        $satpArgs.type = $this.Type
        $satpArgs.device = $this.Device
        $satpArgs.driver = $this.Driver
        $satpArgs.claimoption = $this.ClaimOptions
        $satpArgs.psp = $this.Psp
        $satpArgs.option = $this.Options
        $satpArgs.model = $this.Model

        if ($null -ne $this.Boot) { $satpArgs.boot = $this.Boot }
    }

    <#
    .DESCRIPTION

    Installs the new SATP Claim Rule with the specified properties from the user.
    #>
    [void] AddSatpClaimRule() {
        $satpArgs = Add-CreateArgs -EsxCli $this.EsxCli
        if ($null -ne $this.Force) { $satpArgs.force = $this.Force }

        $this.PopulateSatpArgs($satpArgs)

        try {
            Add-SATPClaimRule -EsxCli $this.EsxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for adding satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Uninstalls the SATP Claim Rule with the specified properties from the user.
    #>
    [void] RemoveSatpClaimRule() {
        $satpArgs = Remove-CreateArgs -EsxCli $this.EsxCli

        $this.PopulateSatpArgs($satpArgs)

        try {
            Remove-SATPClaimRule -EsxCli $this.EsxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for removing satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }
}
