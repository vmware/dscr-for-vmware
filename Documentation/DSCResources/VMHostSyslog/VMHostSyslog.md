# VMHostSyslog

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **LogHost** | Optional | string | The remote host(s) to send logs to. ||
| **CheckSslCerts** | Optional | bool | Verify remote SSL certificates against the local CA Store. ||
| **DefaultTimeout** | Optional | long | Default network retry timeout in seconds if a remote server fails to respond. ||
| **QueueDropMark** | Optional | long | Message queue capacity after which messages are dropped. ||
| **LogDir** | Optional | string | The directory to output local logs to. ||
| **LogDirUnique** | Optional | bool | Place logs in a unique subdirectory of logdir, based on hostname. ||
| **DefaultRotate** | Optional | long | Default number of rotated local logs to keep. ||
| **DefaultSize** | Optional | long | Default size of local logs before rotation, in KiB. ||
| **DropLogRotate** | Optional | long | Number of rotated dropped log files to keep. ||
| **DropLogSize** | Optional | long | Size of dropped log file before rotation, in KiB. ||

## Description

The resource is used to configure the syslog settings on an ESXi node.

## Examples

### Example 1

Updates the syslog settings of the passed ESXi host.

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

Configuration VMHostSyslog_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostSyslog vmHostSyslog {
            Name           = $Name
            Server         = $Server
            Credential     = $Credential
            Loghost        = 'udp:://syslog.domain:514' # RemoteHost
            CheckSslCerts  = $true                      # EnforceSSLCertificates
            DefaultRotate  = 10                         # LocalLoggingDefaultRotations
            DefaultSize    = 100                        # LocalLoggingDefaultRotationSize
            DefaultTimeout = 180                        # DefaultNetworkRetryTimeout
            Logdir         = '/scratch/log'             # LocalLogOutput
            LogdirUnique   = $false                     # LogToUniqueSubdirectory
            DropLogRotate  = 8                          # DroppedLogFileRotations
            DropLogSize    = 50                         # DroppedLogFileRotationSize
            QueueDropMark  = 90                         # MessageQueueDropMark
        }
    }
}
````
