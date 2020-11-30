<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# exceptions
$Script:ConfigurationNotFoundException = "Configuration with name {0} not found"
$Script:CommandIsNotAConfigurationException = "{0} is not a configuration. It is a {1}"
$Script:DuplicateResourceException = "Duplicate resources found with name {0} and type {1}"
$Script:DependsOnResourceNotFoundException = "DependsOn resource of {0} with name {1} was not found"
$Script:DscResourceNotFoundException = "Resource of type: {0} was not found. Try importing it in the configuration file with Import-DscResource"
$Script:ExperimentalFeatureNotEnabledInPsCoreException = 'This module depends on the Invoke-DscResource cmdlet and in order to use it must be enabled with "Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource"'
$Script:NoVsphereConnectionsFoundException = "No active vSphere connection found. Please establish a connection first!"
$Script:NestedMoreThanASingleLevelException = "Nesting configurations, composite resources or regular dsc resources more than a single level of nesting is not supported"
$Script:NestedNodesAreNotSupportedException = "Nesting nodes is not supported."
$Script:TooManyConnectionOnASingleVCenterException = "More than 1 active connection found for '{0}'. Please establish only a single connection."
$Script:VsphereNodesAreOnlySupportedOnPowerShellCoreException = "In order to be able to run vSphere Nodes please switch to a Core version of PowerShell"
$Script:NoConfigurationDetectedForInvokeException = "No configuration has been found! Please supply a configuration via a parameter."
$Script:DscResourcesWithDuplicateKeyPropertiesException = "The Dsc Resource of type '{0}' has multiple entries with the same key properties values. Please ensure all key properties have unique values."

# configurationData exception
$Script:ConfigurationDataDoesNotContainAllNodesException = "ConfigurationData parameter must contain an AllNodes key."
$Script:ConfigurationDataAllNodesKeyIsNotAnArrayException = "ConfigurationData AllNodes key must be an array."
$Script:ConfigurationDataNodeEntryInAllNodesIsNotAHashtableException = "ConfigurationData AllNodes entries must be hashtables."
$Script:ConfigurationDataNodeEntryInAllNodesDoesNotContainNodeNameException = "ConfigurationData AllNodes entries must contain an entry named NodeName."
$Script:DuplicateEntryInAllNodesException = "ConfigurationData AllNodes must not have entries with the same NodeName."

# warnings
$Script:NoVsphereConnectionsFoundForNodeWarning = "No active vSphere connection found for node with name '{0}' and will be skipped. Please establish a connection."
