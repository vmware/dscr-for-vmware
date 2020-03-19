<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = '<server>'
            User = '<user>'
            Password = '<password>'
            VMHostName = '<vmhost name>'
            ScsiLunCanonicalName = '<scsi lun canonical name>'
            ScsiLunPathName = '<scsi lun path name>'
            NfsPath = '<nfs path>'
            NfsHost = '<nfs host>'
        }
    )
}

<#
.DESCRIPTION

Modifies the configuration of the specified SCSI device by changing the Multipath policy to 'Fixed'. The SCSI disk is marked as 'local' and 'SSD'.

Configures the specified SCSI Lun path to the specified SCSI device to be 'Active' and 'Preferred'.

Creates or modifies Vmfs Datastore 'MyVmfsDatastore' with 'version 5' File System and maximum file size of Vmfs: '1MB' on the specified VMHost. The StorageIOControl is 'enabled' and
    the latency period beyond which the storage array is considered congested is '100 milliseconds'.

Creates or modifies Nfs Datastore 'MyNfsDatastore' with 'version 3' File System on the specified Nfs Host and VMHost. The access mode is 'ReadOnly' and the Authentication method is 'AUTH_SYS'.
#>
Configuration VMHost_Storage_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.User, (ConvertTo-SecureString -String $AllNodes.Password -AsPlainText -Force)

        VMHostScsiLun VMHostScsiLun {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            CanonicalName = $AllNodes.ScsiLunCanonicalName
            MultipathPolicy = 'Fixed'
            IsLocal = $true
            IsSsd = $true
        }

        VMHostScsiLunPath VMHostScsiLunPath {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.ScsiLunPathName
            ScsiLunCanonicalName = $AllNodes.ScsiLunCanonicalName
            Active = $true
            Preferred = $true
            DependsOn = '[VMHostScsiLun]VMHostScsiLun'
        }

        VmfsDatastore VmfsDatastore {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyVmfsDatastore'
            Path = $AllNodes.ScsiLunCanonicalName
            Ensure = 'Present'
            FileSystemVersion = '5'
            BlockSizeMB = 1
            StorageIOControlEnabled = $true
            CongestionThresholdMillisecond = 100
            DependsOn = '[VMHostScsiLun]VMHostScsiLun'
        }

        NfsDatastore NfsDatastore {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyNfsDatastore'
            Path = $AllNodes.NfsPath
            Ensure = 'Present'
            NfsHost = $AllNodes.NfsHost
            FileSystemVersion = '3'
            AccessMode = 'ReadOnly'
            AuthenticationMethod = 'AUTH_SYS'
        }
    }
}

VMHost_Storage_Config -ConfigurationData $script:configurationData
