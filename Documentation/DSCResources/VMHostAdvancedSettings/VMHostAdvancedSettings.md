# VMHostAdvancedSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **AdvancedSettings** | Mandatory | hashtable | Hashtable containing the advanced settings of the specified VMHost, where each key-value pair represents one advanced setting - the key is the name of the setting and the value is the desired value for the setting. ||

## Description

The resource is used to update the Advanced Settings of the specified VMHost. If the hashtable contains an invalid Advanced Setting, it is ignored. Values of type 'System.Int32' are not allowed in the hashtable and need to be cast to 'long'.

## Examples

### Example 1

Performs an Update operation on the values of the Advanced Settings specified in the hashtable.

```powershell
Configuration VMHostAdvancedSettings_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostAdvancedSettings VMHostAdvancedSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            AdvancedSettings = @{
                'Annotations.WelcomeMessage' = 'Hello from DSC'
                'BufferCache.FlushInterval' = [long] 20000
                'BufferCache.HardMaxDirty' = [long] 50
                'CBRC.Enable' = $true
                'Cpu.UseMwait' = [long] 1
                'Config.Etc.issue' = 'Contents of /etc/issue'
                'Config.HostAgent.plugins.solo.enableMob' = $true
                'DataMover.MaxHeapSize' = [long] 32
                'HBR.HbrBitmapVMMaxStorageGB' = [long] 65500
                'HBR.HbrMinExtentSizeKB' = [long] 4
                'Misc.WorldletLoadType' = 'low'
                'VMkernel.Boot.useReliableMem' = $false
                'Vpx.Vpxa.config.workingDir' = '/var/log/vmware'
                'UserVars.ProductLockerLocation' = '/locker/packages/vmtoolsRepo/'
            }
        }
    }
}
```
