<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostAuthenticationProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        DomainName = $script:constants.DomainName
    }

    $vmHostAuthenticationProperties
}

function New-MocksForVMHostAuthentication {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenDomainActionIsJoinAndErrorOccursWhileIncludingTheVMHostToTheDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionJoin
    $vmHostAuthenticationProperties.DomainCredential = $script:domainCredential

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithoutDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-VMHostAuthentication -MockWith { throw }.GetNewClosure() -ParameterFilter { $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithoutDomain -and $Domain -eq $script:constants.DomainName -and $Credential -eq $script:domainCredential -and $JoinDomain -and !$Confirm } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsJoin {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionJoin
    $vmHostAuthenticationProperties.DomainCredential = $script:domainCredential

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithoutDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-VMHostAuthentication -MockWith { return $null }.GetNewClosure() -ParameterFilter { $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithoutDomain -and $Domain -eq $script:constants.DomainName -and $Credential -eq $script:domainCredential -and $JoinDomain -and !$Confirm } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsLeaveAndErrorOccursWhileExcludingTheVMHostFromTheDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionLeave

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-VMHostAuthentication -MockWith { throw }.GetNewClosure() -ParameterFilter { $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithDomain -and $LeaveDomain -and $Force -and !$Confirm } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsLeave {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionLeave

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-VMHostAuthentication -MockWith { return $null }.GetNewClosure() -ParameterFilter { $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithDomain -and $LeaveDomain -and $Force -and !$Confirm } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenErrorOccursWhileRetrievingTheVMHostAuthenticationInfo {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    Mock -CommandName Get-VMHostAuthentication -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsJoinAndTheVMHostIsNotIncludedInTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionJoin

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithoutDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsJoinAndTheVMHostIsIncludedInTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionJoin

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsLeaveAndTheVMHostIsNotExcludedFromTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionLeave

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenDomainActionIsLeaveAndTheVMHostIsExcludedFromTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationProperties.DomainAction = $script:constants.DomainActionLeave

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithoutDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenTheVMHostIsIncludedInTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}

function New-MocksWhenTheVMHostIsExcludedFromTheSpecifiedDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAuthenticationProperties = New-VMHostAuthenticationProperties

    $vmHostAuthenticationInfoMock = $script:vmHostAuthenticationInfoWithoutDomain

    Mock -CommandName Get-VMHostAuthentication -MockWith { return $vmHostAuthenticationInfoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostAuthenticationProperties
}
