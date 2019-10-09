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
You need to implement your new resource in separate file in the [DSCResources Folder](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/DSCResources). In the Set(), Test() and Get() methods of your resource, you need to call ConnectVIServer() method from the base class to establish a connection either to  a vCenter or an ESXi. In the finally block of each of the methods(Set, Test and Get), you need to call DisconnectVIServer() method from the base class to close the last open connection to the server.
 ```powershell
  [void] Set() {
      try {
          $this.ConnectVIServer()
          ...
      }
      finally {
          $this.DisconnectVIServer()
      }
  }

  [bool] Test() {
      try {
          $this.ConnectVIServer()
          ...
      }
      finally {
          $this.DisconnectVIServer()
      }
  }

  [MyResource] Get() {
      try {
          $this.ConnectVIServer()
          ...
      }
      finally {
          $this.DisconnectVIServer()
      }
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
            * TestHelpers
                * Mocks
                    * MyResourceMocks.ps1
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

In your unit test file you need to replace VMware PowerCLI modules with the script module that allows PowerCLI cmdlets and types to be mocked. This can be achieved with the helper function **Invoke-TestSetup** located [here](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/TestUtils.ps1). The mock data needed for the Unit Tests should be defined [here](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/Mocks/MockData.ps1). Keep in mind that there could be data already defined you can reuse. A good example is the ```$script:viServer``` variable which can be used when mocking the Connect-VIServer cmdlet. The mocks for the Tests should be defined in this [folder](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/Mocks). For every use case a separate function defining the mocks should be created. For examples you can check the other mock files like [InventoryBaseDSCMocks](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Tests/Unit/TestHelpers/Mocks/InventoryBaseDSCMocks.ps1). The Unit Tests file should look like this:
 ```powershell
   using module VMware.vSphereDSC

   $script:moduleName = 'VMware.vSphereDSC'

   InModuleScope -ModuleName $script:moduleName {
       try {
           $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
           $modulePath = $env:PSModulePath
           $resourceName = 'MyResource'

           . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

           # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
           Invoke-TestSetup

           . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
           . "$unitTestsFolder\TestHelpers\Mocks\MyResourceMocks.ps1"

           Describe 'MyResource\Set' -Tag 'Set' {
               # Define a Context block for each possible use case.
               Context '<Use case description>' {
                   ...
               }
           }

           Describe 'MyResource\Test' -Tag 'Test' {
               # Define a Context block for each possible case.
               Context '<Use case description>' {
                   ...
               }
           }

           Describe 'MyResource\Get' -Tag 'Get' {
               # Define a Context block for each possible case.
               Context '<Use case description>' {
                   ...
               }
           }
       }
       finally {
           # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
           Invoke-TestCleanup -ModulePath $modulePath
       }
   }
 ```

 Basically for the integration tests, you need to test that when invoking [Start-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/start-dscconfiguration?view=powershell-5.1) your configuration is applied, [Test-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/test-dscconfiguration?view=powershell-5.1) to check if the configuration is in the desired state and [Get-DscConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/get-dscconfiguration?view=powershell-5.1) to check the currently applied configuration on the machine.
 ```powershell
  try {
      Describe 'MyResource' {
          Context 'Testing one use case' {
              BeforeAll {
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
  }
  finally {
      # Perform some cleanup like disconnecting from a server.
  }
 ```

 Additionally if you have [DependsOn](https://docs.microsoft.com/en-us/powershell/dsc/configurations/resource-depends-on) in your Configurations, it is recommended to add this test:
 ```powershell
  It 'Should have the following dependency: Resource <my resource name> should depend on Resource <resource name>' {
      # Make sure that the my resource is depending on the right resource.
      $myResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq '<my resource id>' }

      $myResource.DependsOn | Should -Be '<resource id>'
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

### Writing Composite Resources

There are many vSphere objects that can be present in different variations. For example we can create a HA Cluster, Drs Cluster or a Cluster that has both HA and Drs settings specified. Another good example is the Virtual Switch (VSS) which has Security, Shaping, Teaming and Bridge settings.

So for each complex vSphere object, separate DSC Resources should be created and then a Composite Resource should be created that wraps all other Resources into one. You can find more information [here](https://docs.microsoft.com/en-us/powershell/dsc/resources/authoringresourcecomposite) on how to write Composite Resources.

For every complex vSphere object, separate Folder needs to be created that consists of the DSC Resources and the Composite Resource. The folder structure should look like this:

* Root folder of module
    * DSCResources
        * MyResource
            * MyResource.psd1
            * MyResource.schema.psm1
            * MyResourceOne.ps1
            * MyResourceTwo.ps1

To use the Composite Resource it is required to place the **vSphere object folder** below the DSCResources folder. Also the **psd1** and **schema.psm1** should have the same name as the **vSphere object folder** otherwise the Resource would not be found. The different Resources should also be created in the **vSphere object folder**. You can check how the [Cluster Resource](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/DSCResources/Cluster) was implemented for reference.

**Issue** should be created first to discuss if a vSphere object should be separated into multiple DSC Resources and one Composite on the top of it. If the object is found to be too complex for one Resource, the guideline is to separate it into multiple Resources for better maintainability. With this only parts of the object can be configured and if needed with the Composite Resource the whole vSphere object can be configured.

For Composite Resources no Unit and Integration Tests are needed because the different DSC Resources that when combined create the Composite Resource are already tested with both Unit and Integration Tests.

### Style Guidelines

It is recommended to read the [Style Guidelines](https://github.com/vmware/dscr-for-vmware/blob/master/STYLE_GUIDELINES.md) before writing new DSC Resources.
