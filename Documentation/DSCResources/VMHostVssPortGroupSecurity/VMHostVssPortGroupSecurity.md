# VMHostVssPortGroupSecurity

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The Name of the VMHost which is going to be used. ||
| **Name** | Key | string | The Name for the Port Group. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Port Group should be Present or Absent. | Present, Absent |
| **AllowPromiscuous** | Optional | bool | Specifies whether promiscuous mode is enabled for the corresponding Virtual Port Group. ||
| **AllowPromiscuousInherited** | Optional | bool | Specifies whether the AllowPromiscuous setting is inherited from the parent Standard Virtual Switch. ||
| **ForgedTransmits** | Optional | bool | Specifies whether forged transmits are enabled for the corresponding Virtual Port Group. ||
| **ForgedTransmitsInherited** | Optional | bool | Specifies whether the ForgedTransmits setting is inherited from the parent Standard Virtual Switch. ||
| **MacChanges** | Optional | bool | Specifies whether MAC address changes are enabled for the corresponding Virtual Port Group. ||
| **MacChangesInherited** | Optional | bool | Specifies whether the MacChanges setting is inherited from the parent Standard Virtual Switch. ||

## Description

The resource is used to update the Security Policy of the specified Virtual Port Group.

## Examples

### Example 1

The first Resource in the Configuration creates a new Standard Virtual Switch **MyVirtualSwitch** with MTU **1500**. The second Resource in the Configuration creates a new Virtual Port Group **MyVirtualPortGroup** which is associated with the Virtual Switch **MyVirtualSwitch** with VLanId set to **1**. The third Resource in the Configuration updates the Security Policy of Virtual Port Group **MyVirtualPortGroup** by enabling Promiscuous mode, Forged Transmits and Mac Changes. The Security Policy settings are not inherited from the parent Standard Virtual Switch.

```powershell
Configuration VMHostVssPortGroupSecurity_Config {
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
        VMHostVss VMHostStandardSwitch {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVssPortGroup VMHostVssPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            VLanId = 1
            DependsOn = "[VMHostVss]VMHostStandardSwitch"
        }

        VMHostVssPortGroupSecurity VMHostVssPortGroupSecurity {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            Ensure = 'Present'
            AllowPromiscuous = $true
            AllowPromiscuousInherited = $false
            ForgedTransmits = $true
            ForgedTransmitsInherited = $false
            MacChanges = $true
            MacChangesInherited = $false
            DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
        }
    }
}
```
