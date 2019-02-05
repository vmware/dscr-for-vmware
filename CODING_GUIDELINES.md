# Coding guidelines

When writing code for any new DSC Resource, you need to inherit from BaseDSC or VMHostBaseDSC.

If you are configuring ESXi settings you need to inherit from VMHostBaseDSC.
 ```powershell
  [DscResource()]
  MyResource : VMHostBaseDSC
 ```
For any other resource you need to inherit from BaseDSC.
 ```powershell
  [DscResource()]
  MyResource : BaseDSC
 ```
You need to implement your new resource in separate file in the [DSCResources Folder](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/DSCResources). In the Set(), Test() and Get() methods of your resource, you need to call ConnectVIServer() method from the base class to establish a connection either to  a vCenter or an ESXi.
 ```powershell
  [void] Set() {
      $this.ConnectVIServer()
      ...
  }

  [bool] Test() {
      $this.ConnectVIServer()
      ...
  }

  [MyResource] Get() {
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

After you implement it, you need to run the build script [VMware.vSphereDSC.build.ps1](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/VMware.vSphereDSC.build.ps1), which updates the psm1 and psd1 content with your new resource (**When submitting a pull request you do not need to do it as Travis CI will run it for you. This step is only needed if you test it locally**).

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

Basically for the unit tests, you need to test the Set(), Test() and Get() methods of your resource with the different use cases. When developing the unit tests you can run only the tests for a specific method of the **Resource** - for example if you want to run the tests for the **Set** method of **MyResource** you can do the following:

```
 Invoke-Pester -Path ./MyResource.Unit.Tests.ps1 -Tag 'Set'
```

Currently the coverage of the module should be at least **90 percent**, so when writing the unit tests, keep in mind for different use cases (for example if a value is passed/not passed, for array values - null, empty or with multiple elements and so on.).

 ```powershell
  Describe 'MyResource\Set' -Tag 'Set' {
    ...
  }

  Describe 'MyResource\Test' -Tag 'Test' {
    ...
  }

  Describe 'MyResource\Get' -Tag 'Get' {
    ...
  }
 ```

For every PowerCLI cmdlet you use, you need to create mock implementation in the [VMware.VimAutomation.Core Test Module](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/VMware.VimAutomation.Core/VMware.VimAutomation.Core.psm1).
 ```powershell
  function <PowerCLI cmdlet> {
     param(
        [<Type of parameter>] $<Parameter of cmdlet>,
     )

     return <Mocked result of the cmdlet>
  }
 ```

For every VMware.Vim type you use, you need to provide .NET implementation of that type in the [VMware.Vim Types File](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/VMware.VimAutomation.Core/VMwareVimTypes.cs).
 ```cs
  namespace VMware.Vim
  {
      public class <Type Name>
      {
      }
  }
 ```

In your unit test file you need to replace VMware PowerCLI modules with the script modules that allows PowerCLI cmdlets and types to be mocked.
 ```powershell
  $script:modulePath = $env:PSModulePath
  $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
  $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

  function BeforeAllTests {
    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
   }

   function AfterAllTests {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
   }

   # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
   BeforeAllTests

   Describe 'MyResource\Set' -Tag 'Set' {
     ...
   }

   Describe 'MyResource\Test' -Tag 'Test' {
     ...
   }

   Describe 'MyResource\Get' -Tag 'Get' {
     ...
   }

   # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
   AfterAllTests
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

          It 'Should be able to call Get-DscConfiguration without throwing' {
              # Make sure getting the configuration did not fail.
              ...
          }

          It 'Should be able to call Get-DscConfiguration and all parameters should match' {
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

 Additionally if you have [DependsOn](https://docs.microsoft.com/en-us/powershell/dsc/configurations/resource-depends-on) in your Configurations, it is recommended to add this test:
 ```powershell
  It 'Should depend on resource <resource name>' {
      # Make sure that the current resource is depending on the right resource.
      $currentResource = Get-DscConfiguration | Where-Object { $_.Name -eq '<current resource name>' }

      $currentResource.DependsOn | Should -Be '<resource name>'
  }
 ```

The needed Configurations for the Integration Tests should be located in the [Configurations Folder](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Integration/Configurations)

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

### Write Documentation

For every developed resource, there should be a documentation showing how to use the resource and **at least 1** example configuration.
Documentation for every resource should currently be structured like so:

* Root folder of repository
    * Documentation
        * DSCResources
            * MyResource
                * `MyResources.md`
