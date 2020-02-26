<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostSNMPAgent : EsxCliBaseDSC {
    VMHostSNMPAgent() {
        $this.EsxCliCommand = 'system.snmp'
    }

    <#
    .DESCRIPTION

    Specifies the default authentication protocol. Valid values are none, MD5, SHA1.
    #>
    [DscProperty()]
    [string] $Authentication

    <#
    .DESCRIPTION

    Specifies up to ten communities each no more than 64 characters. Format is: 'community1[,community2,...]'. This overwrites previous settings.
    #>
    [DscProperty()]
    [string] $Communities

    <#
    .DESCRIPTION

    Specifies whether to start or stop the SNMP service.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies the SNMPv3 engine id. Must be between 10 and 32 hexadecimal characters. 0x or 0X are stripped if found as well as colons (:).
    #>
    [DscProperty()]
    [string] $EngineId

    <#
    .DESCRIPTION

    Specifies where to source hardware events - IPMI sensors or CIM Indications. Valid values are indications and sensors.
    #>
    [DscProperty()]
    [string] $Hwsrc

    <#
    .DESCRIPTION

    Specifies whether to support large storage for 'hrStorageAllocationUnits' * 'hrStorageSize'. Controls how the agent reports 'hrStorageAllocationUnits', 'hrStorageSize' and 'hrStorageUsed' in 'hrStorageTable'.
    Setting this directive to $true to support large storage with small allocation units, the agent re-calculates these values so they all fit into 'int' and 'hrStorageAllocationUnits' * 'hrStorageSize' gives real size
    of the storage. Setting this directive to $false turns off this calculation and the agent reports real 'hrStorageAllocationUnits', but it might report wrong 'hrStorageSize' for large storage because the value won't fit
    into 'int'.
    #>
    [DscProperty()]
    [nullable[bool]] $LargeStorage

    <#
    .DESCRIPTION

    Specifies the SNMP agent syslog logging level. Valid values are debug, info, warning and error.
    #>
    [DscProperty()]
    [string] $LogLevel

    <#
    .DESCRIPTION

    Specifies a comma separated list of trap oids for traps not to be sent by the SNMP agent. Use the property 'reset' to clear this setting.
    #>
    [DscProperty()]
    [string] $NoTraps

    <#
    .DESCRIPTION

    Specifies the UDP port to poll SNMP agent on. The default is 'udp/161'. May not use ports 32768 to 40959.
    #>
    [DscProperty()]
    [nullable[long]] $Port

    <#
    .DESCRIPTION

    Specifies the default privacy protocol. Valid values are none and AES128.
    #>
    [DscProperty()]
    [string] $Privacy

    <#
    .DESCRIPTION

    Specifies up to five inform user ids. Format is: 'user/auth-proto/-|auth-hash/priv-proto/-|priv-hash/engine-id[,...]', where user is 32 chars max. 'auth-proto' is 'none', 'MD5' or 'SHA1',
    'priv-proto' is 'none' or 'AES'. '-' indicates no hash. 'engine-id' is hex string '0x0-9a-f' up to 32 chars max.
    #>
    [DscProperty()]
    [string] $RemoteUsers

    <#
    .DESCRIPTION

    Specifies whether to return SNMP agent configuration to factory defaults.
    #>
    [DscProperty()]
    [nullable[bool]] $Reset

    <#
    .DESCRIPTION

    Specifies the System contact as presented in 'sysContact.0'. Up to 255 characters.
    #>
    [DscProperty()]
    [string] $SysContact

    <#
    .DESCRIPTION

    Specifies the System location as presented in 'sysLocation.0'. Up to 255 characters.
    #>
    [DscProperty()]
    [string] $SysLocation

    <#
    .DESCRIPTION

    Specifies up to three targets to send SNMPv1 traps to. Format is: 'ip-or-hostname[@port]/community[,...]'. The default port is 'udp/162'.
    #>
    [DscProperty()]
    [string] $Targets

    <#
    .DESCRIPTION

    Specifies up to five local users. Format is: 'user/-|auth-hash/-|priv-hash/model[,...]', where user is 32 chars max. '-' indicates no hash. Model is one of 'none', 'auth' or 'priv'.
    #>
    [DscProperty()]
    [string] $Users

    <#
    .DESCRIPTION

    Specifies up to three SNMPv3 notification targets. Format is: 'ip-or-hostname[@port]/remote-user/security-level/trap|inform[,...]'.
    #>
    [DscProperty()]
    [string] $V3Targets

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $modifyVMHostSNMPAgentMethodArguments = @{}
            if ($null -ne $this.NoTraps) { $modifyVMHostSNMPAgentMethodArguments.notraps = $this.NoTraps }
            if ($null -ne $this.SysContact) { $modifyVMHostSNMPAgentMethodArguments.syscontact = $this.SysContact }
            if ($null -ne $this.SysLocation) { $modifyVMHostSNMPAgentMethodArguments.syslocation = $this.SysLocation }

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName, $modifyVMHostSNMPAgentMethodArguments)
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMHostSNMPAgent($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSNMPAgent] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSNMPAgent]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMHost SNMP Agent should be modified.
    #>
    [bool] ShouldModifyVMHostSNMPAgent($esxCliGetMethodResult) {
        $shouldModifyVMHostSNMPAgent = @()

        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Authentication) -and $this.Authentication -ne $esxCliGetMethodResult.authentication)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Communities) -and $this.Communities -ne $esxCliGetMethodResult.communities)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Enable -and $this.Enable -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.enable))
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.EngineId) -and $this.EngineId -ne $esxCliGetMethodResult.engineid)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Hwsrc) -and $this.Hwsrc -ne $esxCliGetMethodResult.hwsrc)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.LargeStorage -and $this.LargeStorage -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.largestorage))
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.LogLevel) -and $this.LogLevel -ne $esxCliGetMethodResult.loglevel)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.NoTraps -and $this.NoTraps -ne [string] $esxCliGetMethodResult.notraps)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Port -and $this.Port -ne [int] $esxCliGetMethodResult.port)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Privacy) -and $this.Privacy -ne $esxCliGetMethodResult.privacy)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.RemoteUsers) -and $this.RemoteUsers -ne $esxCliGetMethodResult.remoteusers)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.SysContact -and $this.SysContact -ne $esxCliGetMethodResult.syscontact)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.SysLocation -and $this.SysLocation -ne $esxCliGetMethodResult.syslocation)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Targets) -and $this.Targets -ne $esxCliGetMethodResult.targets)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Users) -and $this.Users -ne $esxCliGetMethodResult.users)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.V3Targets) -and $this.V3Targets -ne $esxCliGetMethodResult.v3targets)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Reset -and $this.Reset)

        return ($shouldModifyVMHostSNMPAgent -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Reset = $this.Reset

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.Authentication = $esxCliGetMethodResult.authentication
        $result.Communities = $esxCliGetMethodResult.communities
        $result.Enable = [System.Convert]::ToBoolean($esxCliGetMethodResult.enable)
        $result.EngineId = $esxCliGetMethodResult.engineid
        $result.Hwsrc = $esxCliGetMethodResult.hwsrc
        $result.LargeStorage = [System.Convert]::ToBoolean($esxCliGetMethodResult.largestorage)
        $result.LogLevel = $esxCliGetMethodResult.loglevel
        $result.NoTraps = $esxCliGetMethodResult.notraps
        $result.Port = [int] $esxCliGetMethodResult.port
        $result.Privacy = $esxCliGetMethodResult.privacy
        $result.RemoteUsers = $esxCliGetMethodResult.remoteusers
        $result.SysContact = $esxCliGetMethodResult.syscontact
        $result.SysLocation = $esxCliGetMethodResult.syslocation
        $result.Targets = $esxCliGetMethodResult.targets
        $result.Users = $esxCliGetMethodResult.users
        $result.V3Targets = $esxCliGetMethodResult.v3targets
    }
}
