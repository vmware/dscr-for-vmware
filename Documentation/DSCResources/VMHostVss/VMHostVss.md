# VMHostVss

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VSS should be Present or Absent. | Present, Absent |
| **VssName** | Key | string | The name of the VSS. ||
| **Mtu** | Optional | int | The maximum transmission unit (MTU) associated with this virtual switch in bytes. ||

## Description

The resource is used to configure the basic properties of a Virtual Switch (VSS) on an ESXi node.

## Notes

* The **NumPorts** property is not included. From ESXi 5.5 onwards, ports on standard virtual switches are always **elastic**. The NumPorts value is ignored.

## Examples

### Example 1

Creates a new VSS on an ESXi node.

````powershell
param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostVss_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVss vmHostVSS {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Ensure = [Ensure]::Present
            VssName = 'VSS1'
            Mtu = 1500
        }
    }
}
````

### Example 2

Removes a VSS from an ESXi node.

````powershell
param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostVss_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVss vmHostVSS {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Ensure = [Ensure]::Absent
            VssName = 'VSS2'
        }
    }
}
````
