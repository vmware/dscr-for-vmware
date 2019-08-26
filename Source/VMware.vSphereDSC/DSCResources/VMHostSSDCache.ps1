<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostSSDCache : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Datastore used for swap performance enhancement.
    #>
    [DscProperty(Mandatory)]
    [string] $Datastore

    <#
    .DESCRIPTION

    Specifies the space to allocate on the specified Datastore to implement swap performance enhancements, in MB.
    This value should be less than or equal to the free space capacity of the Datastore.
    #>
    [DscProperty(Mandatory)]
    [long] $SwapSize

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateHostCacheConfiguration($vmHost)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        return !$this.ShouldUpdateHostCacheConfiguration($vmHost)
    }

    [VMHostSSDCache] Get() {
        $result = [VMHostSSDCache]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $result.Name = $vmHost.Name
        $this.PopulateResult($vmHost, $result)

        return $result
    }

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
            $foundDatastore = Get-Datastore -Server $this.Connection -Name $this.Datastore -RelatedObject $vmHost -ErrorAction Stop
            return $foundDatastore
        }
        catch {
            throw "Could not retrieve Datastore $($this.Datastore) for VMHost $($this.Name). For more information: $($_.Exception.Message)"
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

    Converts the passed MB value to GB value by rounding it down.
    #>
    [int] ConvertMBValueToGBValue($mbValue) {
        $megabytesInGB = 1024
        return [int] [Math]::Floor($mbValue * $megabytesInGB * $megabytesInGB / 1GB)
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

        return ($this.ConvertMBValueToGBValue($this.SwapSize) -ne $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize))
    }

    <#
    .DESCRIPTION

    Performs an update on the Host Cache Configuration of the specified VMHost by changing the Swap Size for the
    specified Datastore.
    #>
    [void] UpdateHostCacheConfiguration($vmHost) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)

        if ($this.SwapSize -lt 0) {
            throw "The passed Swap Size $($this.SwapSize) is less than zero."
        }

        if ($this.SwapSize -gt $foundDatastore.FreeSpaceMB) {
            throw "The passed Swap Size $($this.SwapSize) is larger than the free space of the Datastore $($foundDatastore.Name)."
        }

        $hostCacheConfigurationSpec = New-Object VMware.Vim.HostCacheConfigurationSpec
        $hostCacheConfigurationSpec.Datastore = $foundDatastore.ExtensionData.MoRef
        $hostCacheConfigurationSpec.SwapSize = $this.SwapSize

        $hostCacheConfigurationResult = Update-HostCacheConfiguration -VMHostCacheConfigurationManager $vmHostCacheConfigurationManager -Spec $hostCacheConfigurationSpec
        $hostCacheConfigurationTaskState = $null
        $sleepTimeInSeconds = 5

        while ($true) {
            Start-Sleep -Seconds $sleepTimeInSeconds

            $hostCacheConfigurationTask = Get-Task -Server $this.Connection -Id $hostCacheConfigurationResult
            $hostCacheConfigurationTaskState = $hostCacheConfigurationTask.State.ToString()
            if ($hostCacheConfigurationTaskState -ne [TaskInfoState]::Running.ToString() -and $hostCacheConfigurationTaskState -ne [TaskInfoState]::Queued.ToString()) {
                break
            }

            Write-Verbose "Cache Configuration update is $($hostCacheConfigurationTask.PercentComplete) Percent Complete."
        }

        if ($hostCacheConfigurationTaskState -eq [TaskInfoState]::Error.ToString()) {
            throw "An error occured while updating Cache Configuration for VMHost $($this.Name)."
        }
        else {
            Write-Verbose "Cache Configuration was successfully updated for VMHost $($this.Name)."
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Host Cache Configuration from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)
        $datastoreCacheInfo = $this.GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore)

        $result.Datastore = $foundDatastore.Name
        $result.SwapSize = $datastoreCacheInfo.SwapSize
    }
}
