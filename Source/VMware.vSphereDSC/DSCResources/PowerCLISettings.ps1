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
class PowerCLISettings {
    <#
    .DESCRIPTION

    Specifies the scope on which the PowerCLI Settings will be applied.
    LCM is the only possible value for the Settings Scope.
    #>
    [DscProperty(Key)]
    [PowerCLISettingsScope] $SettingsScope

    <#
    .DESCRIPTION

    Specifies the proxy policy for the connection through which Customer Experience Improvement Program (CEIP) data is sent to VMware.
    #>
    [DscProperty()]
    [ProxyPolicy] $CEIPDataTransferProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the server connection mode.
    #>
    [DscProperty()]
    [DefaultVIServerMode] $DefaultVIServerMode = [DefaultVIServerMode]::Unset

    <#
    .DESCRIPTION

    Indicates whether you want to see warnings about deprecated elements.
    #>
    [DscProperty()]
    [nullable[bool]] $DisplayDeprecationWarnings

    <#
    .DESCRIPTION

    Define the action to take when an attempted connection to a server fails due to a certificate error.
    #>
    [DscProperty()]
    [BadCertificateAction] $InvalidCertificateAction = [BadCertificateAction]::Unset

    <#
    .DESCRIPTION

    Specifies if PowerCLI should send anonymous usage information to VMware.
    #>
    [DscProperty()]
    [nullable[bool]] $ParticipateInCeip

    <#
    .DESCRIPTION

    Specifies whether VMware PowerCLI uses a system proxy server to connect to the vCenter Server system.
    #>
    [DscProperty()]
    [ProxyPolicy] $ProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Defines the timeout for Web operations. The default value is 300 sec.
    #>
    [DscProperty()]
    [nullable[int]] $WebOperationTimeoutSeconds

    hidden [string] $Scope = "User"

    [void] Set() {
        $this.ImportRequiredModules()
        $powerCLIConfigurationProperties = $this.GetPowerCLIConfigurationProperties()

        $commandName = 'Set-PowerCLIConfiguration'
        $namesOfPowerCLIConfigurationProperties = $powerCLIConfigurationProperties.Keys

        <#
        For testability we use this function to construct the Set-PowerCLIConfiguration cmdlet instead of using splatting and passing the cmdlet parameters as hashtable.
        At the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
        There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
        #>
        $constructedCommand = $this.ConstructCommandWithParameters($commandName, $powerCLIConfigurationProperties, $namesOfPowerCLIConfigurationProperties)
        Invoke-Expression -Command $constructedCommand
    }

    [bool] Test() {
        $this.ImportRequiredModules()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope
        $powerCLIDesiredConfiguration = $this.GetPowerCLIConfigurationProperties()

        return $this.Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration)
    }

    [PowerCLISettings] Get() {
        $this.ImportRequiredModules()
        $result = [PowerCLISettings]::new()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope

        $this.PopulateResult($powerCLICurrentConfiguration, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Returns all passed PowerCLI configuration properties as a hashtable.
    #>
    [hashtable] GetPowerCLIConfigurationProperties() {
        $powerCLIConfigurationProperties = @{}

        # Adds the Default Scope to the hashtable.
        $powerCLIConfigurationProperties.Add("Scope", $this.Scope)

        if ($this.CEIPDataTransferProxyPolicy -ne [ProxyPolicy]::Unset -and $this.ParticipateInCeip -eq $true) {
            $powerCLIConfigurationProperties.Add("CEIPDataTransferProxyPolicy", $this.CEIPDataTransferProxyPolicy)
        }

        if ($this.DefaultVIServerMode -ne [DefaultVIServerMode]::Unset) {
            $powerCLIConfigurationProperties.Add("DefaultVIServerMode", $this.DefaultVIServerMode)
        }

        if ($null -ne $this.DisplayDeprecationWarnings) {
            $powerCLIConfigurationProperties.Add("DisplayDeprecationWarnings", $this.DisplayDeprecationWarnings)
        }

        if ($this.InvalidCertificateAction -ne [BadCertificateAction]::Unset) {
            $powerCLIConfigurationProperties.Add("InvalidCertificateAction", $this.InvalidCertificateAction)
        }

        if ($null -ne $this.ParticipateInCeip) {
            $powerCLIConfigurationProperties.Add("ParticipateInCeip", $this.ParticipateInCeip)
        }

        if ($this.ProxyPolicy -ne [ProxyPolicy]::Unset) {
            $powerCLIConfigurationProperties.Add("ProxyPolicy", $this.ProxyPolicy)
        }

        if ($null -ne $this.WebOperationTimeoutSeconds) {
            $powerCLIConfigurationProperties.Add("WebOperationTimeoutSeconds", $this.WebOperationTimeoutSeconds)
        }

        return $powerCLIConfigurationProperties
    }

    <#
    .DESCRIPTION

    Constructs the Set-PowerCLIConfiguration cmdlet with the passed properties.
    This function is used instead of splatting because at the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
    There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
    So with this function we can successfully test which properties are passed to the Set-PowerCLIConfiguration cmdlet.
    #>
    [string] ConstructCommandWithParameters($commandName, $properties, $namesOfProperties) {
        $constructedCommand = [System.Text.StringBuilder]::new()

        # Adds the command name to the constructed command.
        [void]$constructedCommand.Append("$commandName ")

        # For every property name we add the property value with the following syntax: '-Property Value'.
        foreach ($propertyName in $namesOfProperties) {
            $propertyValue = $properties.$propertyName

            <#
            For bool values we need to add another '$' sign so the value can be evaluated to bool.
            So we check the type of the value and if it is a boolean we add another '$' sign, because without it the value will
            not be evaluated to boolean and instead it will be evaluated to string which will cause an exception of mismatching types.
            #>
            if ($propertyValue.GetType().Name -eq 'Boolean') {
                [void]$constructedCommand.Append("-$propertyName $")
                [void]$constructedCommand.Append("$propertyValue ")
            }
            else {
                [void]$constructedCommand.Append("-$propertyName $propertyValue ")
            }
        }

        # Adds the confirm:$false to the command to ignore the confirmation.
        [void]$constructedCommand.Append("-Confirm:`$false")

        # Converts the StringBuilder to String and returns the result.
        return $constructedCommand.ToString()
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the current PowerCLI Configuration is equal to the Desired Configuration.
    #>
    [bool] Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration) {
        foreach ($key in $powerCLIDesiredConfiguration.Keys) {
            <#
            Currently works only for properties which are numbers, strings and enums. For more complex types like
            Hashtable the logic needs to be modified to work correctly.
            #>
            if ($powerCLIDesiredConfiguration.$key.ToString() -ne $powerCLICurrentConfiguration.$key.ToString()) {
                return $false
            }
        }

        return $true
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the PowerCLI settings from the server.
    #>
    [void] PopulateResult($powerCLICurrentConfiguration, $result) {
        $result.SettingsScope = $this.SettingsScope
        $result.CEIPDataTransferProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy) { $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.DefaultVIServerMode = if ($null -ne $powerCLICurrentConfiguration.DefaultVIServerMode) { $powerCLICurrentConfiguration.DefaultVIServerMode.ToString() } else { [DefaultVIServerMode]::Unset }
        $result.DisplayDeprecationWarnings = $powerCLICurrentConfiguration.DisplayDeprecationWarnings
        $result.InvalidCertificateAction = if ($null -ne $powerCLICurrentConfiguration.InvalidCertificateAction) { $powerCLICurrentConfiguration.InvalidCertificateAction.ToString() } else { [BadCertificateAction]::Unset }
        $result.ParticipateInCeip = $powerCLICurrentConfiguration.ParticipateInCEIP
        $result.ProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.ProxyPolicy) { $powerCLICurrentConfiguration.ProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.WebOperationTimeoutSeconds = $powerCLICurrentConfiguration.WebOperationTimeoutSeconds
    }
}
