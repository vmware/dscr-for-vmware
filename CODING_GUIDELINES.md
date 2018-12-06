# Coding guidelines

When writing code for any new DSC Resource, you need to inherit from BaseDSC or VMHostBaseDSC.

If you are writing a resource that configures settings of a vCenter, you want to inherit from BaseDSC.
 ```powershell
  [DscResource()]
  MyResource : BaseDSC
 ```

Otherwise, if you are configuring ESXi settings you need to inherit from VMHostBaseDSC.
 ```powershell
  [DscResource()]
  MyResource : VMHostBaseDSC
 ```

You need to implement your new resource in the [VMware.vSphereDSC Module File](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/VMware.vSphereDSC.psm1). In the Set(), Test() and Get() methods of your resource, you need to call ConnectVIServer() method from the base class to establish a connection either to  a vCenter or an ESXi. 
 ```powershell
  [void] Set()
  {
      $this.ConnectVIServer()
      ...
  }

  [bool] Test()
  {
      $this.ConnectVIServer()
      ...
  }

  [MyResource] Get()
  {
      $this.ConnectVIServer()
      ...
  }
 ```

For every property and helper method in your resource, you need to add brief description about what it is in the format:
 ```powershell
  <#
  .DESCRIPTION

  YOUR DESCRIPTION.
  #>
 ```

After you implement it, you need to add it to the [Module Manifest File](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/VMware.vSphereDSC.psd1) (in the DscResourcesToExport array).
 ```powershell
  # DSC resources to export from this module
  DscResourcesToExport = @()
 ```

You need to write example configuration to show how your resource works. You can look at the [Configurations Folder](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Configurations) to see other example configurations.

### Write Tests
All DSC Resources in the module should have tests written using [Pester](https://github.com/pester/Pester) included in the Tests folder.
You are required to provide adequate test coverage for the code you change and have both Unit and Integration tests.

The tests in the module provide examples on how to structure your tests:
* [Unit](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Unit)
* [Integration](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Integration)

Tests should currently be structured like so:

* Root folder of module
    * Tests
        * Unit
            * MyResource.Unit.Tests.ps1
        * Integration
            * MyResource.Integration.Tests.ps1
            * Configurations
                * MyResource
                    * MyResource_Config.ps1

Basically for the unit tests, you need to test the Set(), Test() and Get() methods of your resource with the different usecases.
 ```powershell
  Describe 'MyResource' {
      Describe 'MyResource\Set' {
          ...
      }

      Describe 'MyResource\Test' {
          ...   
      }

      Describe 'MyResource\Get' {
          ...
      }
  }
 ```

For every PowerCLI cmdlet you use, you need to create mock implementation in the [VMware.Vim Test Module](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/VMware.VimAutomation.Core).
 ```powershell
  function <PowerCLI cmdlet>
  {
     param(
        [<Type of parameter>] $<Parameter of cmdlet>,
     )

     return <Mocked result of the cmdlet>
  }
 ```

For every VMware.Vim type you use, you need to provide .NET implementation of that type in the [VMware.Vim Module File](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/VMware.VimAutomation.Core/VMware.VimAutomation.Core.psm1).
 ```powershell
  <#
  Mock types of VMware.Vim assembly for the purpose of unit testing.
  #>

  Add-Type -TypeDefinition @"
   <Add your type here>
  "
 ```

In your unit test file you need to change your VMware.Vim module, so the tests can run with the mock types.
 ```powershell
  $script:modulePath = $env:PSModulePath
  $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
  $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

  Describe 'MyResource' {
      BeforeAll {
          # Arrange
          $env:PSModulePath = $script:mockModuleLocation
          Import-Module -Name VMware.VimAutomation.Core
          ...
      }

      AfterAll {
          Remove-Module -Name VMware.VimAutomation.Core
          $env:PSModulePath = $script:modulePath
          ...
      }
  }
 ```

 Basically for the integration tests, you need to test that when invoking [Start-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/start-dscconfiguration?view=powershell-5.1) your configuration is applied, [Test-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/test-dscconfiguration?view=powershell-5.1) to check if the configuration is in the desired state and [Get-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/get-dscconfiguration?view=powershell-5.1) to check the currently applied configuration on the machine.
 ```powershell
  Describe 'MyResource' {
      Context 'Testing one use case' {
          BeforeEach {
              ...
              Start-DscConfiguration <DSC Config parameters>
              ...
          }

          It 'Should compile and apply the MOF without throwing' {
              # Make sure the configuration did not fail when being applied.
              ...
          }

          It 'Should be able to call Get-DscConfiguration without throwing and all the parameters should match' {
              # Make sure the returned configuration is the desired one.
              ... 
          }

          It 'Should return $true when Test-DscConfiguration is run' {
              # Make sure the configuration is in the desired state.
              ...
          }
      }
  }
 ```

The needed Configurations for the Integration Tests should be located in the [Configurations Folder](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Configurations)

Running the tests:
1. Go to the Tests folder:
 ```powershell
  cd (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests')
 ```

2. The [Test Runner](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/TestRunner.ps1) script gives you the ability to:  
   Run both Unit and Integration Tests:
    ```powershell
     .\TestRunner.ps1 -Integration -Unit
     .\TestRunner.ps1
    ```

   Only Unit Tests
    ```powershell
     .\TestRunner.ps1 -Unit
    ```

   Only Integration Tests
    ```powershell
    .\TestRunner.ps1 -Integration
    ```
