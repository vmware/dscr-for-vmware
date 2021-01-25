# VMHostSNMPAgent

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Authentication** | Optional | string | The default authentication protocol. | MD5, SHA1, none |
| **Communities** | Optional | string | Specifies up to ten communities each no more than 64 characters. Format is: **community1[,community2,...]**. This overwrites previous settings. ||
| **Enable** | Optional | bool | Specifies whether to start or stop the SNMP service. ||
| **EngineId** | Optional | string | The SNMPv3 engine id. Must be between 10 and 32 hexadecimal characters. 0x or 0X are stripped if found as well as colons (:). ||
| **Hwsrc** | Optional | string | Specifies where to source hardware events - IPMI sensors or CIM Indications. | indications, sensors |
| **LargeStorage** | Optional | bool | Specifies whether to support large storage for **hrStorageAllocationUnits** * **hrStorageSize**. Controls how the agent reports **hrStorageAllocationUnits**, **hrStorageSize** and **hrStorageUsed** in **hrStorageTable**. Setting this directive to **$true** to support large storage with small allocation units, the agent re-calculates these values so they all fit into **int** and **hrStorageAllocationUnits** * **hrStorageSize** gives real size of the storage. Setting this directive to **$false** turns off this calculation and the agent reports real **hrStorageAllocationUnits**, but it might report wrong **hrStorageSize** for large storage because the value won't fit into **int**. ||
| **LogLevel** | Optional | string | The SNMP agent syslog logging level. | debug, info, warning, error |
| **NoTraps** | Optional | string | Specifies a comma separated list of trap oids for traps not to be sent by the SNMP agent. Use the property **reset** to clear this setting. ||
| **Port** | Optional | long | The UDP port to poll SNMP agent on. The default is **udp/161**. May not use ports 32768 to 40959. ||
| **Privacy** | Optional | string | The default privacy protocol. | AES128, none |
| **RemoteUsers** | Optional | string | Specifies up to five inform user ids. Format is: **user/auth-proto/-\|auth-hash/priv-proto/-\|priv-hash/engine-id[,...]**, where user is 32 chars max. **auth-proto** is **none**, **MD5** or **SHA1**, **priv-proto** is **none** or **AES**. '-' indicates no hash. **engine-id** is hex string '0x0-9a-f' up to 32 chars max. ||
| **SysContact** | Optional | string | The System contact as presented in **sysContact.0**. Up to 255 characters. ||
| **SysLocation** | Optional | string | The System location as presented in **sysLocation.0**. Up to 255 characters. ||
| **Targets** | Optional | string | Specifies up to three targets to send SNMPv1 traps to. Format is: **ip-or-hostname[@port]/community[,...]**. The default port is **udp/162**. ||
| **Users** | Optional | string | Specifies up to five local users. Format is: **user/-\|auth-hash/-\|priv-hash/model[,...]**, where user is 32 chars max. '-' indicates no hash. Model is one of **none**, **auth** or **priv**. ||
| **V3Targets** | Optional | string | Specifies up to three SNMPv3 notification targets. Format is: **ip-or-hostname[@port]/remote-user/security-level/trap\|inform[,...]**. ||
| **Reset** | Optional | bool | Specifies whether to return SNMP agent configuration to factory defaults. ||

## Description

The resource is used to modify the SNMP agent configuration on the specified VMHost.

## Examples

### Example 1

Modifies the configuration of the SNMP agent of the VMHost by setting the authentication protocol to **SHA1**, the privacy protocol to **AES128**, the log level to **info** and the UDP port to poll SNMP agent on to **161**. It also starts the SNMP service, **CIM Indications** to source hardware events from and supports large storage.

```powershell
Configuration VMHostSNMPAgent_ModifyVMHostSNMPAgentConfiguration_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostSNMPAgent VMHostSNMPAgent {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Authentication = 'SHA1'
            Enable = $true
            Hwsrc = 'indications'
            LargeStorage = $true
            LogLevel = 'info'
            Port = 161
            Privacy = 'AES128'
        }
    }
}
```

### Example 2

Returns the SNMP agent configuration on the VMHost to factory defaults.

```powershell
Configuration VMHostSNMPAgent_ResetVMHostSNMPAgentConfiguration_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostSNMPAgent VMHostSNMPAgent {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Reset = $true
        }
    }
}
```
