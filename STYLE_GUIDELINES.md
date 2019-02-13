# Desired State Configuration Resources for VMware Style Guidelines & Best Practices

In order to provide clean and consistent code, please follow the [style guidelines](#style-guidelines) listed below when contributing to the repository.

## Table of Contents

- [Style Guidelines](#style-guidelines)
  - [General](#general)
    - [Descriptive Names](#descriptive-names)
    - [Correct Parameter Usage in Function and Cmdlet Calls](#correct-parameter-usage-in-function-and-cmdlet-calls)
    - [Correct Format for Arrays](#correct-format-for-arrays)
    - [Correct Format for Hashtables or Objects](#correct-format-for-hashtables-or-objects)
    - [Correct use of single and double quotes](#correct-use-of-single-and-double-quotes)
    - [Correct Format for Comments](#correct-format-for-comments)
    - [Correct Format for Keywords](#correct-format-for-keywords)
  - [Whitespace](#whitespace)
    - [No Trailing Whitespace After Backticks](#no-trailing-whitespace-after-backticks)
    - [Newline at End of File](#newline-at-end-of-file)
    - [No More Than Two Consecutive Newlines](#no-more-than-two-consecutive-newlines)
    - [Two Newlines After Closing Brace](#two-newlines-after-closing-brace)
    - [One Space Between Type and Variable Name](#one-space-between-type-and-variable-name)
    - [One Space on Either Side of Operators](#one-space-on-either-side-of-operators)
    - [One Space Between Keyword and Parenthesis](#one-space-between-keyword-and-parenthesis)
  - [Functions](#functions)
    - [Function Names Use Pascal Case](#function-names-use-pascal-case)
    - [Function Names Use Verb-Noun Format](#function-names-use-verb-noun-format)
    - [Function Names Use Approved Verbs](#function-names-use-approved-verbs)
    - [Functions Have Comment-Based Help](#functions-have-comment-based-help)
  - [Parameters](#parameters)
    - [Parameter Names Use Pascal Case](#parameter-names-use-pascal-case)
  - [Variables](#variables)
    - [Variable Names Use Camel Case](#variable-names-use-camel-case)
    - [Script, Environment and Global Variable Names Include Scope](#script-environment-and-global-variable-names-include-scope)
- [Best Practices](#best-practices)
  - [General Best Practices](#general-best-practices)
    - [Avoid Using Hardcoded Computer Name](#avoid-using-hardcoded-computer-name)
    - [Avoid Empty Catch Blocks](#avoid-empty-catch-blocks)
    - [Ensure Null is on Left Side of Comparisons](#ensure-null-is-on-left-side-of-comparisons)
    - [Avoid Global Variables](#avoid-global-variables)
    - [Use Declared Local and Script Variables More Than Once](#use-declared-local-and-script-variables-more-than-once)
    - [Use PSCredential for All Credentials](#use-pscredential-for-all-credentials)
  - [Pester Tests](#pester-tests)
    - [Capitalized Pester Assertions](#capitalized-pester-assertions)


## Style Guidelines

### General

#### Descriptive Names

Use descriptive, clear, and full names for all variables, parameters, and functions.
All names must be at least more than **2** characters.
No abbreviations should be used.

**Bad:**

```powershell
$vmh = Get-VMHost
```

**Bad:**

```powershell
$sixty = 60
```

**Bad:**

```powershell
function Get-Something {
    ...
}
```

**Bad:**

```powershell
function Set-VMHost {
    param (
        $myVMH
    )
    ...
}
```

**Good:**

```powershell
$vmHost = Get-VMHost
```

**Good:**

```powershell
$secondsInAMinute = 60
```

**Good:**

```powershell
function New-DNSConfig {
    ...
}
```

**Good:**

```powershell
function Update-DNSConfig {
    param (
        [VMware.Vim.HostNetworkSystem] $NetworkSystem
    )
    ...
}
```

#### Correct Parameter Usage in Function and Cmdlet Calls

Use named parameters for function and cmdlet calls rather than positional parameters.
Named parameters help other developers who are unfamiliar with your code to better
understand it.

When calling a function with many long parameters, use parameter splatting. If
splatting is used, then all the parameters should be in the splat.
More help on splatting can be found in the article
[About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting).

**Bad:**

Not using named parameters.

```powershell
Get-VMHost MyVM
```

**Good:**

```powershell
Get-VMHost -Name MyVM
```

#### Correct Format for Arrays

Arrays should be written in one of the following formats.

If an array is declared on a single line, then there should be a single space
between each element in the array. If arrays written on a single line tend to be
long, please consider using one of the alternative ways of writing the array.

**Bad:**

Array elements are not format consistently.

```powershell
$ntpServer = @( 'ntp server 1', `
'ntp server 2', `
'ntp server 3'
)
```

**Bad:**

There are no single space beetween the elements in the array.

```powershell
$ntpServer = @('ntp server 1','ntp server 2','ntp server 3')
```

**Bad:**

There are multiple array elements on the same row.

```powershell
$ntpServer = @(
    'ntp server 1', 'ntp server 2', `
    'ntp server 3', `
    'ntp server 4', 'ntp server 5'
)
```

**Good:**

```powershell
$ntpServer = @('ntp server 1', 'ntp server 2', 'ntp server 3')
```

**Good:**

```powershell
$ntpServer = @(
    'ntp server 1',
    'ntp server 2',
    'ntp server 3'
)
```

**Good:**

```powershell
$ntpServer = @(
    'ntp server 1'
    'ntp server 2'
    'ntp server 3'
    'ntp server 4'
    'ntp server 5'
)
```

#### Correct Format for Hashtables or Objects

Hashtables and Objects should be written in the following format.
Each property should be on its own line indented once.

**Bad:**

```powershell
$performanceIntervalArgs = @{ Key = $currentPerformanceInterval.Key
Name = $currentPerformanceInterval.Name
Enabled = $this.SpecifiedOrCurrentValue($this.Enabled, $currentPerformanceInterval.Enabled)
Level = $this.SpecifiedOrCurrentValue($this.Level, $currentPerformanceInterval.Level)
SamplingPeriod = $this.SpecifiedOrCurrentValue($this.IntervalMinutes * $this.SecondsInAMinute, $currentPerformanceInterval.SamplingPeriod)
Length = $this.SpecifiedOrCurrentValue($this.PeriodLength * $this.Period, $currentPerformanceInterval.Length)
}
```

**Good:**

```powershell
$performanceIntervalArgs = @{
    Key = $currentPerformanceInterval.Key
    Name = $currentPerformanceInterval.Name
    Enabled = $this.SpecifiedOrCurrentValue($this.Enabled, $currentPerformanceInterval.Enabled)
    Level = $this.SpecifiedOrCurrentValue($this.Level, $currentPerformanceInterval.Level)
    SamplingPeriod = $this.SpecifiedOrCurrentValue($this.IntervalMinutes * $this.SecondsInAMinute, $currentPerformanceInterval.SamplingPeriod)
    Length = $this.SpecifiedOrCurrentValue($this.PeriodLength * $this.Period, $currentPerformanceInterval.Length)
}
```

#### Correct use of single and double quotes

Single quotes should always be used to delimit string literals wherever possible.
Double quoted string literals may only be used when it contains ($) expressions
that need to be evaluated.

**Bad:**

```powershell
$vmhost = "VMHost with name was not found."
```

**Good:**

```powershell
$vmhost = 'VMHost with name was not found.'
```

**Good:**

```powershell
$vmhost = 'VMHost with name $($this.Name) was not found.'
```

#### Correct Format for Comments

There should not be any commented-out code in checked-in files.
The first letter of the comment should be capitalized.

Single line comments should be on their own line and start with a single pound-sign followed by a single space.
The comment should be indented the same amount as the following line of code.

Comments that are more than one line should use the ```<# #>``` format rather than the single pound-sign.
The opening and closing brackets should be on their own lines.
The brackets should be indented the same amount as the following line of code.

**Bad:**

```powershell
 <#
    .DESCRIPTION
    Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi.
    #>
    [DscProperty(Key)]
    [string] $Server
```

**Bad:**

```powershell
    # Empty array specified as desired, but current is not an empty array, so update VMHost NTP Server.
 return $true
```

**Good:**

```powershell
 <#
 .DESCRIPTION

 Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi.
 #>
 [DscProperty(Key)]
 [string] $Server
```

**Good:**

```powershell
 # Empty array specified as desired, but current is not an empty array, so update VMHost NTP Server.
 return $true
```

#### Correct Format for Keywords

PowerShell reserved Keywords should be in all lower case and should
be immediately followed by a space if there is non-whitespace characters
following (for example, an open brace).

The following is the current list of PowerShell reserved keywords in
PowerShell 5.1:

```powershell
begin, break, catch, class, continue, data, define do, dynamicparam, else,
elseif, end, enum, exit, filter, finally, for, foreach, from, function
hidden, if, in, inlinescript, param, process, return, static, switch,
throw, trap, try, until, using, var, while
```

This list may change in newer versions of PowerShell.

The latest list of PowerShell reserved keywords can also be found
on [this page](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_keywords?view=powershell-5.1).

**Bad:**

```powershell
# Missing space after keyword and before open bracket
foreach($item in $list)
```

**Bad:**

```powershell
# Capital letters in keyword
TRY
```

**Bad:**

```powershell
# Capital letters in 'in' and 'foreach' keyword
ForEach ($item In $list)
```

**Bad:**

```powershell
try
{
    # Do some work
}
```

**Good:**

```powershell
foreach ($item in $list)
```

**Good:**

```powershell
try {
    # Do some work
}
```

### Whitespace

#### No Trailing Whitespace After Backticks

Backticks should always be directly followed by a newline.

#### Newline at End of File

All files must end with a newline, see [StackOverflow.](http://stackoverflow.com/questions/5813311/no-newline-at-end-of-file)

#### No More Than Two Consecutive Newlines

Code should not contain more than two consecutive newlines unless they are contained in a here-string.

**Bad:**

```powershell
function Get-VMHost {
    Write-Verbose -Message 'Getting VMHost'


    return $vmHost
}
```

**Good:**

```powershell
function Get-VMHost {
    Write-Verbose -Message 'Getting VMHost'
    return $vmHost
}
```

#### Two Newlines After Closing Brace

Each closing curly brace **ending** a function, conditional block, loop, etc. should be followed by exactly two newlines unless it is directly followed by another closing brace.
If the closing brace is followed by another closing brace or continues a conditional or switch block, there should be only one newline after the closing brace.

**Bad:**

```powershell
function Get-VMHost {
    Write-Verbose -Message 'Getting VMHost'
    return $vmHost
} Get-VMHost
```

**Bad:**

```powershell
function Get-VMHost {
    Write-Verbose -Message 'Getting VMHost'

    if ($myBoolean) {
        return $vmHost
    }

    else {
        return 0
    }

}
Get-VMHost
```

**Good:**

```powershell
function Get-VMHost {
    Write-Verbose -Message 'Getting VMHost'

    if ($myBoolean) {
        return $vmHost
    }
    else {
        return 0
    }
}

Get-VMHost
```

#### One Space Between Type and Variable Name

If you must declare a variable type, type declarations should be separated from the variable name by a single space.

**Bad:**

```powershell
function Get-VMHost {
    [CmdletBinding()]
    param ()

    [VMHost]$vmHost = <VMHost>
}
```

**Good:**

```powershell
function Get-VMHost {
    [CmdletBinding()]
    param ()

    [VMHost] $vmHost = <VMHost>
}
```

#### One Space on Either Side of Operators

There should be one blank space on either side of all operators.

**Bad:**

```powershell
function Get-Number {
    [CmdletBinding()]
    param ()

    $number=2+4-5*9/6
}
```

**Bad:**

```powershell
function Get-Message {
    [CmdletBinding()]
    param ()

    if ('example'-eq'example'-or'magic') {
        Write-Verbose -Message 'Example found.'
    }
}
```

**Good:**

```powershell
function Get-Number {
    [CmdletBinding()]
    param ()

    $number = 2 + 4 - 5 * 9 / 6
}
```

**Good:**

```powershell
function Get-Message {
    [CmdletBinding()]
    param ()

    if ('example' -eq 'example' -or 'magic') {
        Write-Verbose -Message 'Example found.'
    }
}
```

#### One Space Between Keyword and Parenthesis

If a keyword is followed by a parenthesis, there should be single space between the keyword and the parenthesis.

**Bad:**

```powershell
function Get-Message {
    [CmdletBinding()]
    param ()

    if('example' -eq 'example' -or 'magic'){
        Write-Verbose -Message 'Example found.'
    }

    foreach($example in $examples){
        Write-Verbose -Message $example
    }
}
```

**Good:**

```powershell
function Get-Message {
    [CmdletBinding()]
    param ()

    if ('example' -eq 'example' -or 'magic') {
        Write-Verbose -Message 'Example found.'
    }

    foreach ($example in $examples) {
        Write-Verbose -Message $example
    }
}
```

### Functions

#### Function Names Use Pascal Case

Function names must use PascalCase. This means that each concatenated word is capitalized.

**Bad:**

```powershell
function get-vmhost {
    # ...
}
```

**Good:**

```powershell
function Get-VMHost {
    # ...
}
```

#### Function Names Use Verb-Noun Format

All function names must follow the standard PowerShell Verb-Noun format.

**Bad:**

```powershell
function VMHostGetter {
    # ...
}
```

**Good:**

```powershell
function Get-VMHost {
    # ...
}
```

#### Function Names Use Approved Verbs

All function names must use [approved verbs](https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx).

**Bad:**

```powershell
function Normalize-String {
    # ...
}
```

**Good:**

```powershell
function ConvertTo-NormalizedString {
    # ...
}
```

#### Functions Have Comment-Based Help

All functions should have comment-based help with the correct syntax directly above the function.
Comment-help should include at least the SYNOPSIS section and a PARAMETER section for each parameter.

**Bad:**

```powershell
# Creates an event
function New-Event {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter()]
        [ValidateSet('operational', 'debug', 'analytic')]
        [String]
        $Channel = 'operational'
    )
    # Implementation...
}
```

**Good:**

```powershell
<#
    .SYNOPSIS
        Creates an event

    .PARAMETER Message
        Message to write

    .PARAMETER Channel
        Channel where message should be stored

    .EXAMPLE
        New-Event -Message 'Attempting to connect to server' -Channel 'debug'
#>
function New-Event {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter()]
        [ValidateSet('operational', 'debug', 'analytic')]
        [String]
        $Channel = 'operational'
    )
    # Implementation
}
```

### Parameters

#### Parameter Names Use Pascal Case

All parameters must use PascalCase.  This means that each concatenated word is capitalized.

**Bad:**

```powershell
function Get-VMHost {
    [CmdletBinding()]
    param (
        $VMHOSTNAME
    )
}
```

**Bad:**

```powershell
function Get-VMHost {
    [CmdletBinding()]
    param (
        $vmhost
    )
}
```

**Good:**

```powershell
function Get-VMHost {
    [CmdletBinding()]
    param (
        [Parameter()]
        $VMHost
    )
}
```

### Variables

#### Variable Names Use Camel Case

Variable names should use camelCase.

**Bad:**

```powershell
function Write-Log {
    $VerboseMessage = 'New log message'
    Write-Verbose $VerboseMessage
}
```

**Bad:**

```powershell
function Write-Log {
    $verbosemessage = 'New log message'
    Write-Verbose $verbosemessage
}
```

**Good:**

```powershell
function Write-Log {
    $verboseMessage = 'New log message'
    Write-Verbose $verboseMessage
}
```

#### Script, Environment and Global Variable Names Include Scope

Script, environment, and global variables must always include their scope in the variable name unless the 'using' scope is needed.
The script and global scope specifications should be all in lowercase.
Script and global variable names following the scope should use camelCase.

**Bad:**

```powershell
$fileCount = 0
$GLOBAL:MYRESOURCENAME = 'MyResource'

function New-File {
    $fileCount++
    Write-Verbose -Message "Adding file to $MYRESOURCENAME to $ENV:COMPUTERNAME."
}
```

**Good:**

```powershell
$script:fileCount = 0
$global:myResourceName = 'MyResource'

function New-File {
    $script:fileCount++
    Write-Verbose -Message "Adding file to $global:myResourceName to $env:computerName."
}
```

## Best Practices

### General Best Practices

#### Avoid Using Hardcoded Computer Name

Using hardcoded computer names exposes sensitive information on your machine.
Use a parameter or environment variable instead if a computer name is necessary.

**Bad:**

```powershell
Invoke-Command -Port 0 -ComputerName 'hardcodedName'
```

**Good:**

```powershell
Invoke-Command -Port 0 -ComputerName $env:computerName
```

#### Avoid Empty Catch Blocks

Empty catch blocks are not necessary.
Most errors should be thrown or at least acted upon in some way.
If you really don't want an error to be thrown or logged at all, use the ErrorAction parameter with the SilentlyContinue value instead.

**Bad:**

```powershell
try {
    Get-Command -Name Invoke-NotACommand
}
catch {}
```

**Good:**

```powershell
Get-Command -Name Invoke-NotACommand -ErrorAction SilentlyContinue
```

#### Ensure Null is on Left Side of Comparisons

When comparing a value to ```$null```, ```$null``` should be on the left side of the comparison.
This is due to an issue in PowerShell.
If ```$null``` is on the right side of the comparison and the value you are comparing it against happens to be a collection, PowerShell will return true if the collection *contains* ```$null``` rather than if the entire collection actually *is* ```$null```.
Even if you are sure your variable will never be a collection, for consistency, please ensure that ```$null``` is on the left side of all comparisons.

**Bad:**

```powershell
if ($myArray -eq $null) {
    Remove-AllItems
}
```

**Good:**

```powershell
if ($null -eq $myArray) {
    Remove-AllItems
}
```

#### Avoid Global Variables

Avoid using global variables whenever possible.
These variables can be edited by any other script that ran before your script or is running at the same time as your script.
Use them only with extreme caution, and try to use parameters or script/local variables instead.

**Bad:**

```powershell
$global:configurationName = 'MyConfigurationName'
...
Set-MyConfiguration -ConfigurationName $global:configurationName
```

**Good:**

```powershell
$script:configurationName = 'MyConfigurationName'
...
Set-MyConfiguration -ConfigurationName $script:configurationName
```

#### Use Declared Local and Script Variables More Than Once

Don't declare a local or script variable if you're not going to use it.
This creates excess code that isn't needed

#### Use PSCredential for All Credentials

PSCredentials are more secure than using plaintext username and passwords.

**Bad:**

```powershell
function Get-Settings {
    param (
        [String]
        $Username

        [String]
        $Password
    )
    ...
}
```

**Good:**

```powershell
function Get-Settings {
    param (
        [PSCredential]
        [Credential()]
        $UserCredential
    )
}
```

### Pester Tests

#### Capitalized Pester Assertions

Pester assertions should all start with capital letters. This makes the code easier to read.

**Bad:**

```powershell
it 'Should return something' {
    get-targetresource @testParameters | should -be 'something'
}
```

**Good:**

```powershell
It 'Should return something' {
    Get-TargetResource @testParameters | Should -Be 'something'
}
```
