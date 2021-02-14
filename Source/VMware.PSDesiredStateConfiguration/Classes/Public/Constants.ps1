<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:DuplicateResourceException = "Duplicate resources found with name {0} and type {1}"
$script:DependsOnResourceNotFoundException = "DependsOn resource of {0} with name {1} was not found"
$script:DscResourceNotFoundException = "Resource of type: {0} was not found. Try importing it in the configuration file with Import-DscResource"
$script:ExperimentalFeatureNotEnabledInPsCoreException = 'This module depends on the Invoke-DscResource cmdlet and in order to use it must be enabled with "Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource"'
$script:NoVsphereConnectionsFoundException = "No active vSphere connection found. Please establish a connection first!"
$script:NestedMoreThanASingleLevelException = "Nesting configurations, composite resources or regular dsc resources more than a single level of nesting is not supported"
$script:NestedNodesAreNotSupportedException = "Nesting nodes is not supported."
$script:TooManyConnectionOnASingleVCenterException = "More than 1 active connection found for '{0}'. Please establish only a single connection."
$script:VsphereNodesAreOnlySupportedOnPowerShellCoreException = "In order to be able to run vSphere Nodes please switch to a Core version of PowerShell"
$script:NoConfigurationDetectedForInvokeException = "No configuration has been found! Please supply a configuration via a parameter."
$script:DscResourcesWithDuplicateKeyPropertiesException = "The Dsc Resource of type '{0}' has multiple entries with the same key properties values. Please ensure all key properties have unique values."

$script:ConfigurationDataDoesNotContainAllNodesException = "ConfigurationData parameter must contain an AllNodes key."
$script:ConfigurationDataAllNodesKeyIsNotAnArrayException = "ConfigurationData AllNodes key must be an array."
$script:ConfigurationDataNodeEntryInAllNodesIsNotAHashtableException = "ConfigurationData AllNodes entries must be hashtables."
$script:ConfigurationDataNodeEntryInAllNodesDoesNotContainNodeNameException = "ConfigurationData AllNodes entries must contain an entry named NodeName."
$script:DuplicateEntryInAllNodesException = "ConfigurationData AllNodes must not have entries with the same NodeName."

$script:NoVsphereConnectionsFoundForNodeWarning = "No active vSphere connection found for node with name '{0}' and will be skipped. Please establish a connection."
