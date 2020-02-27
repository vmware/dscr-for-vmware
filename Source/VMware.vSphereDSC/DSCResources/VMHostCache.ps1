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
class VMHostCache : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Datastore used for swap performance enhancement.
    #>
    [DscProperty(Key)]
    [string] $DatastoreName

    <#
    .DESCRIPTION

    Specifies the space to allocate on the specified Datastore to implement swap performance enhancements, in GB.
    This value should be less than or equal to the free space capacity of the Datastore.
    #>
    [DscProperty(Mandatory)]
    [double] $SwapSizeGB

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateHostCacheConfiguration($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateHostCacheConfiguration($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostCache] Get() {
        try {
            $result = [VMHostCache]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    hidden [int] $NumberOfFractionalDigits = 3

    <#
    .DESCRIPTION

    Retrieves the Cache Configuration Manager of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostCacheConfigurationManager($vmHost) {
        try {
            $vmHostCacheConfigurationManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.CacheConfigurationManager -ErrorAction Stop
            return $vmHostCacheConfigurationManager
        }
        catch {
            throw "Could not retrieve the Cache Configuration Manager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore for Host Cache Configuration from the server if it exists.
    If the Datastore does not exist, it throws an exception.
    #>
    [PSObject] GetDatastore($vmHost) {
        try {
            $foundDatastore = Get-Datastore -Server $this.Connection -Name $this.DatastoreName -RelatedObject $vmHost -ErrorAction Stop
            return $foundDatastore
        }
        catch {
            throw "Could not retrieve Datastore $($this.DatastoreName) for VMHost $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Cache Info for the specified Datastore from the Host Cache Configuration.
    If the Datastore is not enabled for swap performance, it throws an exception.
    #>
    [PSObject] GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore) {
        $datastoreCacheInfo = $vmHostCacheConfigurationManager.CacheConfigurationInfo | Where-Object { $_.Key -eq $foundDatastore.ExtensionData.MoRef }
        if ($null -eq $datastoreCacheInfo) {
            throw "Datastore $($foundDatastore.Name) could not be found in enabled for swap performance Datastores."
        }

        return $datastoreCacheInfo
    }

    <#
    .DESCRIPTION

    Converts the passed MB value to GB value by rounding it down with 3 fractional digits in the return value.
    #>
    [double] ConvertMBValueToGBValue($mbValue) {
        return [Math]::Round($mbValue * 1MB / 1GB, $this.NumberOfFractionalDigits)
    }

    <#
    .DESCRIPTION

    Converts the passed GB value to MB value by rounding it down.
    #>
    [long] ConvertGBValueToMBValue($gbValue) {
        return [long] [Math]::Round($gbValue * 1GB / 1MB)
    }

    <#
    .DESCRIPTION

    Checks if the Host Cache Configuration should be updated for the specified VMHost by checking
    if the current Swap Size is equal to the desired one for the specified Datastore.
    #>
    [bool] ShouldUpdateHostCacheConfiguration($vmHost) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)
        $datastoreCacheInfo = $this.GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore)

        return ($this.SwapSizeGB -ne $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize))
    }

    <#
    .DESCRIPTION

    Performs an update on the Host Cache Configuration of the specified VMHost by changing the Swap Size for the
    specified Datastore.
    #>
    [void] UpdateHostCacheConfiguration($vmHost) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)

        if ($this.SwapSizeGB -lt 0) {
            throw "The passed Swap Size $($this.SwapSizeGB) is less than zero."
        }

        if ($this.SwapSizeGB -gt $foundDatastore.FreeSpaceGB) {
            throw "The passed Swap Size $($this.SwapSizeGB) is larger than the free space of the Datastore $($foundDatastore.Name)."
        }

        $hostCacheConfigurationSpec = New-Object VMware.Vim.HostCacheConfigurationSpec
        $hostCacheConfigurationSpec.Datastore = $foundDatastore.ExtensionData.MoRef
        $hostCacheConfigurationSpec.SwapSize = $this.ConvertGBValueToMBValue($this.SwapSizeGB)

        $hostCacheConfigurationResult = Update-HostCacheConfiguration -VMHostCacheConfigurationManager $vmHostCacheConfigurationManager -Spec $hostCacheConfigurationSpec
        $hostCacheConfigurationTask = Get-Task -Server $this.Connection -Id $hostCacheConfigurationResult

        try {
            Wait-Task -Task $hostCacheConfigurationTask -ErrorAction Stop
        }
        catch {
            throw "An error occured while updating Cache Configuration for VMHost $($this.Name). For more information: $($_.Exception.Message)"
        }

        Write-VerboseLog -Message "Cache Configuration was successfully updated for VMHost {0}." -Arguments @($this.Name)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Host Cache Configuration from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)
        $datastoreCacheInfo = $this.GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore)

        $result.DatastoreName = $foundDatastore.Name
        $result.SwapSizeGB = $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize)
    }
}
