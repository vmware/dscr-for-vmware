using module VMware.vSphereDSC
$script:modulePath = $env:PSModulePath
$script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
$script:moduleName = 'VMware.vSphereDSC'


Describe 'Compare-Settings'{

    BeforeAll {
        # Arrange
        $env:PSModulePath = $script:mockModuleLocation
        $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
        if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers')
        {
            throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
        }

        Import-Module -Name VMware.VimAutomation.Core
        Import-Module .\Source\VMware.vSphereDSC\VMware.vSphereDSC.Helper.psm1
    }

    AfterAll {
        Remove-Module -Name VMware.VimAutomation.Core
        $env:PSModulePath = $script:modulePath
    }

    Context 'Desired and current settings match'{
        $desiredState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }
        $currentState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }

        $result = Compare-Settings -DesiredState $desiredState -CurrentState $currentState

        it 'should return false' {
            $result | should be $false
        }
    }
    Context 'Desired and current settings match'{
        $desiredState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 5"
        }
        $currentState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }

        $result = Compare-Settings -DesiredState $desiredState -CurrentState $currentState

        it 'should return true' {
            $result | should be $true
        }
    }
    Context 'Desired state has additional setting'{
        $desiredState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
            key4 = "value 4"
        }
        $currentState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }

        $result = Compare-Settings -DesiredState $desiredState -CurrentState $currentState

        it 'should return true' {
            $result | should be $true
        }
    }
    Context 'Current state has additional setting'{
        $desiredState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }
        $currentState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
            key4 = "value 4"
        }

        $result = Compare-Settings -DesiredState $desiredState -CurrentState $currentState

        it 'should return false' {
            $result | should be $false
        }
    }
    Context 'Current state not supplied'{
        $desiredState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }

        $result = Compare-Settings -DesiredState $desiredState

        it 'should return true' {
            $result | should be $true
        }
    }
    Context 'Desired state not supplied'{
        $currentState = @{
            key1 = "value 1"
            key2 = "value 2"
            key3 = "value 3"
        }

        $result = Compare-Settings -CurrentState $currentState

        it 'should return false' {
            $result | should be $false
        }
    }
}