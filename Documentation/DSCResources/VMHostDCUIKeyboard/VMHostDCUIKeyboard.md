# VMHostDCUIKeyboard

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Layout** | Mandatory | string | The name of the Direct Console User Interface Keyboard Layout. ||
| **NoPersist** | Optional | bool | Specifies whether the layout is applied only for the current boot. ||

## Description

The resource is used to modify the Direct Console User Interface Keyboard Layout.

## Examples

### Example 1

Modifies the Direct Console User Interface Keyboard Layout to be **US Default**.

```powershell
Configuration VMHostDCUIKeyboard_ModifyVMHostDCUIKeyboardLayout_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostDCUIKeyboard VMHostDCUIKeyboard {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Layout = 'US Default'
        }
    }
}
```
