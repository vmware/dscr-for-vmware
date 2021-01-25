# VMHostSatpClaimRule

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the SATP Claim Rule should be Present or Absent. |Present, Absent|
| **RuleName** | Key | string | Name of the SATP Claim Rule. ||
| **PSPOptions** | Optional | string | PSP options for the SATP Claim Rule. ||
| **Transport** | Optional | string | Transport Property of the Satp Claim Rule. ||
| **Description** | Optional | string | Description string to set when adding the SATP Claim Rule. ||
| **Vendor** | Optional | string | Vendor string to set when adding the SATP Claim Rule. ||
| **Boot** | Optional | bool | System default rule added at boot time. ||
| **Type** | Optional | string | Claim type for the SATP Claim Rule. ||
| **Device** | Optional | string | Device of the SATP Claim Rule. ||
| **Driver** | Optional | string | Driver string for the SATP Claim Rule. ||
| **ClaimOptions** | Optional | string | Claim option string for the SATP Claim Rule. ||
| **Psp** | Optional | string | Default PSP for the SATP Claim Rule. ||
| **Options** | Optional | string | Option string for the SATP Claim Rule. ||
| **Model** | Optional | string | Model string for the SATP Claim Rule. ||
| **Force** | Optional | bool | Value, which ignores validity checks and install the rule anyway. ||

## Description

The resource is used to create or remove SATP Claim Rules of a ESXi host.

## Examples

### Example 1

Creates new SATP Claim Rule for the passed ESXi host.

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

Configuration VMHostSatpClaimRule_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostSatpClaimRule vmHostSatpClaimRule {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Ensure = "Present"
            RuleName = "VMW_SATP_LOCAL"
            Transport = "VMW_SATP_LOCAL Transport"
            Description = "Description of VMW_SATP_LOCAL Claim Rule."
            Type = "transport"
            Psp = "VMW_PSP_MRU"
        }
    }
}
````

### Example 2

Removes SATP Claim Rule for the passed ESXi host.

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

Configuration VMHostSatpClaimRule_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostSatpClaimRule vmHostSatpClaimRule {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Ensure = "Absent"
            RuleName = "VMW_SATP_LOCAL"
            Transport = "VMW_SATP_LOCAL Transport"
            Description = "Description of VMW_SATP_LOCAL Claim Rule."
            Type = "transport"
            Psp = "VMW_PSP_MRU"
        }
    }
}
````
