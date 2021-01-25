# VMHostAgentVM

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **AgentVmDatastore** | Optional | string | The Datastore used for deploying Agent VMs on this VMHost. ||
| **AgentVmNetwork** | Optional | string | The Management Network used for Agent VMs on this VMHost. ||

## Description

The resource is used to update the configuration of Agent Virtual Machine resources of the specified VMHost. If the AgentVm settings are not passed or set to $null, the values are cleared on the VMHost. The entire configuration is set each time since all values are overwritten.

## Examples

### Example 1

Performs an Update operation on the configuration of Agent Virtual Machine resources of the specified VMHost by setting the Datastore and Network to $null. The behaviour will be the same if AgentVmDatastore and AgentVmNetwork are not passed at all here. So to clear the values both cases are valid - Not passing them at all or setting them to $null.

```powershell
Configuration VMHostAgentVM_Config {
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
        VMHostAgentVM VMHostAgentVM {
            Name = $Name
            Server = $Server
            Credential = $Credential
            AgentVmDatastore = $null
            AgentVmNetwork = $null
        }
    }
}
```

### Example 2

Performs an Update operation on the configuration of Agent Virtual Machine resources of the specified VMHost by setting the Datastore to 'MyDatastore' and Network to $null.

```powershell
Configuration VMHostAgentVM_Config {
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
        VMHostAgentVM VMHostAgentVM {
            Name = $Name
            Server = $Server
            Credential = $Credential
            AgentVmDatastore = 'MyDatastore'
            AgentVmNetwork = $null
        }
    }
}
```

### Example 3

Performs an Update operation on the configuration of Agent Virtual Machine resources of the specified VMHost by setting the Datastore to $null and Network to 'MyNetwork'.

```powershell
Configuration VMHostAgentVM_Config {
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
        VMHostAgentVM VMHostAgentVM {
            Name = $Name
            Server = $Server
            Credential = $Credential
            AgentVmDatastore = $null
            AgentVmNetwork = 'MyNetwork'
        }
    }
}
```

### Example 4

Performs an Update operation on the configuration of Agent Virtual Machine resources of the specified VMHost by setting the Datastore to 'MyDatastore' and Network to 'MyNetwork'.

```powershell
Configuration VMHostAgentVM_Config {
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
        VMHostAgentVM VMHostAgentVM {
            Name = $Name
            Server = $Server
            Credential = $Credential
            AgentVmDatastore = 'MyDatastore'
            AgentVmNetwork = 'MyNetwork'
        }
    }
}
```
