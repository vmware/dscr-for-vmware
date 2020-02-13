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
class VMHostIScsiHbaTarget : VMHostIScsiHbaBaseDSC {
    <#
    .DESCRIPTION

    Specifies the address of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [string] $Address

    <#
    .DESCRIPTION

    Specifies the TCP port of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [int] $Port

    <#
    .DESCRIPTION

    Specifies the name of the iSCSI Host Bus Adapter of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [string] $IScsiHbaName

    <#
    .DESCRIPTION

    Specifies the type of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [IScsiHbaTargetType] $TargetType

    <#
    .DESCRIPTION

    Specifies whether the iSCSI Host Bus Adapter target should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the iSCSI name of the iSCSI Host Bus Adapter target. It is required for Static iSCSI Host Bus Adapter targets.
    #>
    [DscProperty()]
    [string] $IScsiName

    <#
    .DESCRIPTION

    Indicates that the CHAP setting is inherited from the iSCSI Host Bus Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritChap

    <#
    .DESCRIPTION

    Indicates that the Mutual CHAP setting is inherited from the iSCSI Host Bus Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritMutualChap

    <#
    .DESCRIPTION

    Specifies the <Address>:<Port> that uniquely identifies an iSCSI Host Bus Adapter target.
    #>
    hidden [string] $IPEndPoint

    hidden [string] $CreateIScsiHbaTargetMessage = "Creating iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}."
    hidden [string] $ModifyIScsiHbaTargetMessage = "Modifying CHAP settings of iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}."
    hidden [string] $RemoveIScsiHbaTargetMessage = "Removing iSCSI Host Bus Adapter target with IP address {0} from iSCSI Host Bus Adapter device {1}."

    hidden [string] $CouldNotCreateIScsiHbaTargetMessage = "Could not create iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}. For more information: {2}"
    hidden [string] $CouldNotModifyIScsiHbaTargetMessage = "Could not modify CHAP settings of iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveIScsiHbaTargetMessage = "Could not remove iSCSI Host Bus Adapter target with IP address {0} from iSCSI Host Bus Adapter device {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $iScsiHbaTarget) {
                    $this.NewIScsiHbaTarget($iScsiHba)
                }
                else {
                    $this.ModifyIScsiHbaTarget($iScsiHbaTarget)
                }
            }
            else {
                if ($null -ne $iScsiHbaTarget) {
                    $this.RemoveIScsiHbaTarget($iScsiHbaTarget)
                }
            }
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
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $iScsiHbaTarget) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyCHAPSettings($iScsiHbaTarget.AuthenticationProperties, $this.InheritChap, $this.InheritMutualChap)
                }
            }
            else {
                $result = ($null -eq $iScsiHbaTarget)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostIScsiHbaTarget] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostIScsiHbaTarget]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            $this.PopulateResult($result, $iScsiHbaTarget)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the iSCSI Host Bus Adapter target with the specified IPEndPoint for the specified iSCSI Host Bus Adapter if it exists.
    #>
    [PSObject] GetIScsiHbaTarget($iScsiHba) {
        $getIScsiHbaTargetParams = @{
            Server = $this.Connection
            IScsiHba = $iScsiHba
            IPEndPoint = $this.IPEndPoint
            Type = $this.TargetType.ToString()
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-IScsiHbaTarget @getIScsiHbaTargetParams
    }

    <#
    .DESCRIPTION

    Creates a new iSCSI Host Bus Adapter target of the specified type with the specified address for the specified iSCSI Host Bus Adapter.
    #>
    [void] NewIScsiHbaTarget($iScsiHba) {
        $newIScsiHbaTargetParams = @{
            Server = $this.Connection
            Address = $this.Address
            Port = $this.Port
            IScsiHba = $iScsiHba
            Type = $this.TargetType.ToString()
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($this.TargetType -eq [IScsiHbaTargetType]::Static) { $newIScsiHbaTargetParams.IScsiName = $this.IScsiName }
        $this.PopulateCmdletParametersWithCHAPSettings($newIScsiHbaTargetParams, $this.InheritChap, $this.InheritMutualChap)

        try {
            Write-VerboseLog -Message $this.CreateIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            New-IScsiHbaTarget @newIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotCreateIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the CHAP settings of the specified iSCSI Host Bus Adapter target.
    #>
    [void] ModifyIScsiHbaTarget($iScsiHbaTarget) {
        $setIScsiHbaTargetParams = @{
            Server = $this.Connection
            Target = $iScsiHbaTarget
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $this.PopulateCmdletParametersWithCHAPSettings($setIScsiHbaTargetParams, $this.InheritChap, $this.InheritMutualChap)

        try {
            Write-VerboseLog -Message $this.ModifyIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            Set-IScsiHbaTarget @setIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotModifyIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified iSCSI Host Bus Adapter target from its iSCSI Host Bus Adapter.
    #>
    [void] RemoveIScsiHbaTarget($iScsiHbaTarget) {
        $removeIScsiHbaTargetParams = @{
            Server = $this.Connection
            Target = $iScsiHbaTarget
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            Remove-IScsiHbaTarget @removeIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotRemoveIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $iScsiHbaTarget) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.IScsiHbaName = $this.IScsiHbaName
        $result.Force = $this.Force

        if ($null -ne $iScsiHbaTarget) {
            $result.Address = $iScsiHbaTarget.Address
            $result.Port = $iScsiHbaTarget.Port
            $result.TargetType = $iScsiHbaTarget.Type.ToString()
            $result.IScsiName = $iScsiHbaTarget.IScsiName
            $result.InheritChap = $iScsiHbaTarget.AuthenticationProperties.ChapInherited
            $result.ChapType = $iScsiHbaTarget.AuthenticationProperties.ChapType.ToString()
            $result.ChapName = [string] $iScsiHbaTarget.AuthenticationProperties.ChapName
            $result.InheritMutualChap = $iScsiHbaTarget.AuthenticationProperties.MutualChapInherited
            $result.MutualChapEnabled = $iScsiHbaTarget.AuthenticationProperties.MutualChapEnabled
            $result.MutualChapName = [string] $iScsiHbaTarget.AuthenticationProperties.MutualChapName
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Address = $this.Address
            $result.Port = $this.Port
            $result.TargetType = $this.TargetType
            $result.IScsiName = $this.IScsiName
            $result.InheritChap = $this.InheritChap
            $result.ChapType = $this.ChapType
            $result.ChapName = $this.ChapName
            $result.InheritMutualChap = $this.InheritMutualChap
            $result.MutualChapEnabled = $this.MutualChapEnabled
            $result.MutualChapName = $this.MutualChapName
            $result.Ensure = [Ensure]::Absent
        }
    }
}
