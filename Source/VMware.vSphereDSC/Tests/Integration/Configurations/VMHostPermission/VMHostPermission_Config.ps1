<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostPermission_CreateVMHostRoles_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostRole ($AllNodes.VMHostRoleResourceName + $AllNodes.RoleOneName) {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.RoleOneName
            Ensure = 'Present'
        }

        VMHostRole ($AllNodes.VMHostRoleResourceName + $AllNodes.RoleTwoName) {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.RoleTwoName
            Ensure = 'Present'
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForDatacenterEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.DatacenterEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'Datacenter'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForVMHostEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMHostEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'VMHost'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForDatastoreEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.DatastoreEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'Datastore'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForResourcePoolEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.ResourcePoolEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'ResourcePool'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForVMEntityWithEmptyEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.OneResourcePoolEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_CreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.OneResourcePoolAndOneVAppEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Present'
            Propagate = $AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_ModifyVMHostPermissionRoleAndPropagateBehaviour_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.OneResourcePoolAndOneVAppEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleTwoName
            Ensure = 'Present'
            Propagate = !$AllNodes.PropagatePermission
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForDatacenterEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.DatacenterEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'Datacenter'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForVMHostEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMHostEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'VMHost'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForDatastoreEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.DatastoreEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'Datastore'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForResourcePoolEntity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.ResourcePoolEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'ResourcePool'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForVMEntityWithEmptyEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.EmptyEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.OneResourcePoolEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostPermission $AllNodes.VMHostPermissionResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            EntityName = $AllNodes.VMEntityName
            EntityLocation = $AllNodes.OneResourcePoolAndOneVAppEntityLocation
            EntityType = 'VM'
            PrincipalName = $AllNodes.VMHostUserAccountName
            RoleName = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostPermission_RemoveVMHostRoles_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostRole ($AllNodes.VMHostRoleResourceName + $AllNodes.RoleOneName) {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.RoleOneName
            Ensure = 'Absent'
        }

        VMHostRole ($AllNodes.VMHostRoleResourceName + $AllNodes.RoleTwoName) {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.RoleTwoName
            Ensure = 'Absent'
        }
    }
}
