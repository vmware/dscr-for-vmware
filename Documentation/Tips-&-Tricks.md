# Tips & Tricks

## Tools
### Editor
You can choose any editor that you prefer to work with PowerShell code. I personally prefer an use [Visual Studio Code](https://code.visualstudio.com) with the [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell).

### Git
Since you will be working with a **GitHub** repository, you will need to know how to use **Git**. A good starting point will be the [Official Git Documentation](https://git-scm.com/docs). You can download **Git** from [here](https://git-scm.com/downloads).

## Formatting Guidelines
When developing new **VMware DSC Resources** you should follow the [Formatting Guidelines](https://github.com/vmware/dscr-for-vmware/blob/master/FORMATTING_GUIDELINES.md). This is the content of the **settings.json** file in [Visual Studio Code](https://code.visualstudio.com) which we use. In **VSC** you just need to place the settings from the [Formatting Guidelines](https://github.com/vmware/dscr-for-vmware/blob/master/FORMATTING_GUIDELINES.md) file into your **settings.json** and this way the rules will be applied for your code.

Basic **formatting rules** if you are using another editor:
* Open brace should be on the same line.
* After a closing brace there should be a new line.
* The tab size should be equal to 4 spaces.
* Trailing whitespaces should be trimmed.

## Guidelines for working with the repository and Git
Contributions to the repository are only available through **Pull Requests**. They are **reviewed** and **merged** by the maintainers of the repository.

To add content to the repository via **PR** requires basic **Git** knowledge. Here is a list of **git** commands that you will need to use on a daily basis:

**git status** - Displays paths that have differences between the index file and the current HEAD commit, paths that have differences between the working tree and the index file, and paths in the working tree that are not tracked by Git.

**git log** - Shows the commit logs.

**git checkout `<branch>`** - To prepare for working on `<branch>`, switch to it by updating the index and the files in the working tree, and by pointing HEAD at the branch. Local modifications to the files in the working tree are kept, so that they can be committed to the `<branch>`.

**git add `<files>`** - Updates the index using the current content found in the working tree, to prepare the content staged for the next commit.

**git commit -s -m `<your message>`** - Stores the current contents of the index in a new commit along with a log message from the user describing the changes and adds Signed-off-by line by the committer at the end of the commit log message.

**git push** - Updates remote refs using local refs, while sending objects necessary to complete the given refs.

**git pull** - Incorporates changes from a remote repository into the current branch.

**git merge** - Incorporates changes from the named commits (since the time their histories diverged from the current branch) into the current branch.

## Writing VMware DSC Resources
In the implementation of **VMware DSC Resources** you can use one of the following depending on the **Resource**:

* **PowerCLI** Cmdlets
* **vSphere API** through **PowerCLI Views Layer**
* **ESXCLI** Commands through **Get-EsxCli** cmdlet

The prefered option is to use **PowerCLI** cmdlets if the functionality is covered by a **cmdlet**. For example if you want to update the **log.level** Advanced Setting value of a vCenter you can use the following cmdlet from **PowerCLI**:
```powershell
 Set-AdvancedSetting -AdvancedSetting 'log.level' -Value <desired value>
```

If **PowerCLI** cmdlet is not available to cover the functionality you are developing you can use the **vSphere API** through **PowerCLI Views Layer**. The tricky part here is that you need to define separate wrapper function in the [VMware.vSphereDSC Helper](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/VMware.vSphereDSC.Helper.psm1) that inside calls the method from the API. This way we enable testability and we can easily mock the wrapper function in the Unit Tests. For example if we want to update some Service Policy, we can define the following function that inside calls the **vSphere API**:
```powershell
 function Update-ServicePolicy {
     [CmdletBinding()]
     param(
         [VMware.Vim.HostServiceSystem] $ServiceSystem,
         [string] $ServiceId,
         [string] $ServicePolicyValue
     )

     $ServiceSystem.UpdateServicePolicy($ServiceId, $ServicePolicyValue)
 }
```

The third option is using **ESXCLI** Commands through **Get-EsxCli** cmdlet which is not so common but there are special cases where the first two options are not applicable. Like the case of adding and removing **SATP Claim Rules**. Here we need to again define separate wrapper function in the [VMware.vSphereDSC Helper](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/VMware.vSphereDSC.Helper.psm1) that inside calls the **ESXCLI** Command. This way we again enable testability and we can easily mock the wrapper function in the Unit Tests. For example if we want to add new **SATP Claim Rule**, we can define the following function that inside calls the **ESXCLI** Command:
```powershell
 # Example how to retrieve the EsxCli
 Get-EsxCli -Server <Specify the Server here> -VMHost <Specify the VMHost here> -V2

 function Add-SATPClaimRule {
     [CmdletBinding()]
     param(
         [PSObject] $EsxCli,
         [Hashtable] $SatpArgs
     )

     $EsxCli.storage.nmp.satp.rule.add.Invoke($SatpArgs)
 }
```

## Writing Unit Tests for VMware DSC Resources
Unit Tests for **VMware.vSphereDSC Resources** should follow the following template:
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
             # Define separate context for every usecase your resource covers.
             Context '<Usecase description>' {
                 BeforeAll {
                     # Here you should mock all cmdlets and function you are going to use in the Set method.
                     # Arrange
                     $resourceProperties = New-MocksForCurrentUsecase
                     $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                 }

                 It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                 }

                 # Here the mock is the executed operation (cmdlet or PowerShell function) in the Set() method (New, Remove, Update, etc)
                 It 'Should call the mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = '<Operation Name>'
                        ParameterFilter = {<All parameters comparison>}
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                 }
             }
         }
         
         Describe 'MyResource\Test' -Tag 'Test' {
             # Define separate context for every usecase your resource covers.
             Context '<Usecase description>' {
                 BeforeAll {
                     # Here you should mock all cmdlets and function you are going to use in the Test method.
                     # Arrange
                     $resourceProperties = New-MocksForCurrentUsecase
                     $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                 }

                 It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                 }

                 # Depending on the use case the result should be either true or false.
                 It 'Should return $true/$false when ...' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                 }
             }
         }

         Describe 'MyResource\Get' -Tag 'Get' {
             # Define separate context for every usecase your resource covers.
             Context '<Usecase description>' {
                 BeforeAll {
                     # Here you should mock all cmdlets and function you are going to use in the Get method.
                     # Arrange
                     $resourceProperties = New-MocksForCurrentUsecase
                     $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                 }

                 It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                 }

                 It 'Should retrieve the correct settings from the Resource properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    # For each property of the result verify that it is the correct value.
                    $resuly.Name | Should -Be '<expected Name>'
                }
             }
         }
     }
  }
```

## Writing Integration Tests for VMware DSC Resources
Integration Tests for **VMware.vSphereDSC Resources** should follow the following template:
```powershell
 param(
     [Parameter(Mandatory = $true)]
     [string]
     $Name,

     [Parameter(Mandatory = $true)]
     [string]
     $Server,

     [Parameter(Mandatory = $true)]
     [string]
     $User,

     [Parameter(Mandatory = $true)]
     [string]
     $Password
 )

 script:dscResourceName = 'Name of the resource'
 $script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
 $script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
 $script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

 # Compile the configuration file to mof.
 . $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

 Describe "$($script:dscResourceName)_Integration" {
     # Define separate Context for every Usecase(You also need separate Configuration for every Usecase).
     Context "When using configuration <Configuration Name>" {
         BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = '<Path to the mof file for the current Usecase>'
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = '<Path to the mof file for the current Usecase>'
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            # Assert
            # Assert that every property returned from the Get() method is the expected one.
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }
     }
 }
```

Both templates(**Unit** and **Integration**) contain the basic things you need to write your tests. Depending on the case you will need to add more lines of code(Like connection to the server in the case of **Integration** tests).
