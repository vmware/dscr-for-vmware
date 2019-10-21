# PowerCLISettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **SettingsScope** | Key | PowerCLISettingsScope | Specifies the scope on which the PowerCLI Settings will be applied. |LCM|
| **CEIPDataTransferProxyPolicy** | Optional | ProxyPolicy | Specifies the proxy policy for the connection through which Customer Experience Improvement Program (CEIP) data is sent to VMware. |NoProxy, UseSystemProxy, Unset|
| **DefaultVIServerMode** | Optional | DefaultVIServerMode | Specifies the server connection mode. |Single, Multiple, Unset|
| **DisplayDeprecationWarnings** | Optional | bool | Indicates whether you want to see warnings about deprecated elements. ||
| **InvalidCertificateAction** | Optional | BadCertificateAction | Define the action to take when an attempted connection to a server fails due to a certificate error. |Ignore, Warn, Prompt, Fail, Unset|
| **ParticipateInCeip** | Optional | bool | Specifies if PowerCLI should send anonymous usage information to VMware. ||
| **ProxyPolicy** | Optional | ProxyPolicy | Specifies whether VMware PowerCLI uses a system proxy server to connect to the vCenter Server system. |NoProxy, UseSystemProxy, Unset|
| **WebOperationTimeoutSeconds** | Optional | int | Defines the timeout for Web operations. The default value is 300 sec. ||

## Description

The resource is used to Update the PowerCLI Configuration settings of the LCM. **User Scope** PowerCLI Configuration settings are updated with this resource. The LCM runs with Windows System account, so the settings will be stored for the user that runs LCM PowerShell. If a user runs a Configuration with this resource, the settings will be preserved for all future Configurations that run on that LCM.

## Examples

### Example 1

Updates the ParticipateInCeip, InvalidCertificateAction, DefaultVIServerMode and DisplayDeprecationWarnings PowerCLI Configuration settings.

````powershell
Configuration PowerCLISettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        PowerCLISettings powerCLISettings {
            SettingsScope = 'LCM'
            ParticipateInCeip = $false
            InvalidCertificateAction = 'Warn'
            DefaultVIServerMode = 'Multiple'
            DisplayDeprecationWarnings = $false
        }
    }
}
````
