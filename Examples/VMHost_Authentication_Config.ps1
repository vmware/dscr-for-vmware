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
            DomainName = '<domain name>'
            DomainUsername = '<domain username>'
            DomainPassword = '<domain password>'
            DatastoreName = '<datastore name>'
        }
    )
}

<#
.DESCRIPTION

Includes the specified VMHost in the specified domain.

Creates Nfs User 'MyNfsUser' with password 'MyNfsUserPassword1!' on the specified VMHost.

Creates/modifies Role 'MyDscRole' on the specified VMHost. The applied Privileges of Role 'MyDscRole' should be: 'Host.Inventory.AddStandaloneHost',
    'Host.Inventory.CreateCluster', 'Host.Inventory.MoveHost', 'System.Anonymous', 'System.Read' and 'System.View'.

Creates VMHostAccount 'MyVMHostAccount' on the specified VMHost with password 'MyAccountPass1!'. The DSC Resource also creates Permission
    for Principal 'MyVMHostAccount' and Role 'MyDscRole'.

Creates/modifies Permission for the specified Datastore Entity, Principal 'MyVMHostAccount' and Role 'Admin' on the specified VMHost.
    The Permission is not propagated to the child Inventory Items of Datastore Entity.
#>
Configuration VMHost_Authentication_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.User, (ConvertTo-SecureString -String $AllNodes.Password -AsPlainText -Force)
        $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.DomainUsername, (ConvertTo-SecureString -String $AllNodes.DomainPassword -AsPlainText -Force)

        VMHostAuthentication VMHostAuthentication {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = $AllNodes.VMHostName
            DomainName = $AllNodes.DomainName
            DomainAction = 'Join'
            DomainCredential = $DomainCredential
        }

        NfsUser NfsUser {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyNfsUser'
            Password = 'MyNfsUserPassword1!'
            Ensure = 'Present'
            DependsOn = '[VMHostAuthentication]VMHostAuthentication'
        }

        VMHostRole VMHostRole {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'MyDscRole'
            Ensure = 'Present'
            PrivilegeIds = @(
                'Host.Inventory.AddStandaloneHost',
                'Host.Inventory.CreateCluster',
                'Host.Inventory.MoveHost',
                'System.Anonymous',
                'System.Read',
                'System.View'
            )
        }

        VMHostAccount VMHostAccount {
            Server = $AllNodes.Server
            Credential = $Credential
            Id = 'MyVMHostAccount'
            Ensure = 'Present'
            Role = 'MyDscRole'
            AccountPassword = 'MyAccountPass1!'
            Description = 'MyVMHostAccount Description'
            DependsOn = '[VMHostRole]VMHostRole'
        }

        VMHostPermission VMHostPermission {
            Server = $AllNodes.Server
            Credential = $Credential
            EntityName = $AllNodes.DatastoreName
            EntityLocation = ''
            EntityType = 'Datastore'
            PrincipalName = 'MyVMHostAccount'
            RoleName = 'Admin'
            Ensure = 'Present'
            Propagate = $false
            DependsOn = '[VMHostAccount]VMHostAccount'
        }
    }
}

VMHost_Authentication_Config -ConfigurationData $script:configurationData
