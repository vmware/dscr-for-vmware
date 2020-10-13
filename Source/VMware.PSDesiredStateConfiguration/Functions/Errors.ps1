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

$Script:ConfigurationNotFoundException = "Configuration with name {0} not found"
$Script:CommandIsNotAConfigurationException = "{0} is not a configuration. It is a {1}"
$Script:DuplicateResourceException = "Duplicate resources found with name {0} and type {1}"
$Script:DependsOnResourceNotFoundException = "DependsOn resource of {0} with name {1} was not found"
$Script:DscResourceNotFoundException = "Resource of type: {0} was not found. Try importing it in the configuration file with Import-DscResource"
$Script:ExperimentalFeatureNotEnabledInPsCore = 'This module depends on the Invoke-DscResource cmdlet and in order to use it must be enabled with "Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource"'

