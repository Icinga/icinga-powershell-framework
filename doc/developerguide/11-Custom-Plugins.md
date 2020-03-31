# Developer Guide: Custom Plugins

With the [Icinga PowerShell Framework](https://icinga.com/docs/windows/latest) you have the possibility to create new check plugins with very small effort. Below you will find a step-by-step tutorial for writing an example one.

## Creating A New Module

The best approach for creating a custom plugin is by creating an independent module which is installed in your PowerShell modules directly. This will ensure you are not overwriting your custom data with possible framework updates.

In this guide, we will assume the name of the module is `icinga-powershell-plugintutorial`.

At first we will have to create a new module. Navigate to the PowerShell modules folder the Framework itself is installed to. In this tutorial we will assume the location is

```powershell
C:\Program Files\WindowsPowerShell\Modules
```

Now create a new folder with the name `icinga-powershell-plugintutorial` and navigate into it.

As we require a `psm1` file which contains our code, we will create a new file with the name `icinga-powershell-plugintutorial.psm1`. This will allow the PowerShell autoloader to load the module automaticly.

**Note:** It could be possible, depending on your [execution policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6), that your module is not loaded properly. If this is the case, you can try to unblock the file by opening a PowerShell and use the `Unblock-File` Cmdelet

```powershell
Unblock-File -Path 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-plugintutorial\icinga-powershell-plugintutorial.psm1'
```

## Testing The Module

Once the module files are created and unblocked, we can start testing if the autoloader is properly working and our module is detected.

For this open the file `icinga-powershell-plugintutorial.psm1` in your prefered editor and add the following code snippet

```powershell
function Test-MyIcingaPluginTutorialCommand()
{
    Write-Host 'Module was loaded';
}
```

Now open a **new** PowerShell terminal or write `powershell` into an already open PowerShell prompt and execute the command `Test-MyIcingaPluginTutorialCommand`.

If everything went properly, you should now read the output `Module was loaded` in our prompt. If not, you can try to import the module by using

```powershell
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-plugintutorial\icinga-powershell-plugintutorial.psm1';
```

inside your console prompt. After that try again to execute the command `Test-MyIcingaPluginTutorialCommand` and check if it works this time. If not, you might check the naming of your module to ensure `folder name` and `.psm1 file name` is identical.

Once this is working, we can remove the function again as we no longer require it.

## Create A New Plugin

Once everything is working properly we can create our starting function we later use to execute our plugin.

For naming guidelines we will have to begin with the `Invoke-IcingaCheck` naming and an identifier of what are going to achieve with our plugin. This is `mandatory` to ensure all auto-generation Cmdlets are still working. In our example we will simply name it `Tutorial`.

So lets get started with the function

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Our code belongs here
}
```

### Basic Plugin Architecture

A basic plugin contains of multiple parts. At first we general `arguments` to parse thresholds through. In addition to that we will make use of several functions to create our check and check results. The functions [New-IcingaCheck](01-New-IcingaCheck), [New-IcingaCheckPackage](02-New-IcingaCheckPackage) and `New-IcingaCheckResult` will do the work for us.

### Writing Our Base-Skeleton

For our plugin we will start with `param()` to parse arguments to our module, create a check objects and return the result.

At first we will create a variable inside our `Start-IcingaAgentServiceTest` function.

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning  = $null,
        $Critical = $null
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check = New-IcingaCheck `
                -Name 'Tutorial';

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $Check -Compile)
}
```

To test this module, we can call another PowerShell instance within our current session and execute the code. This will ensure, we are always loading changes we are making:

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial; }
```

Our tutorial plugin will now output the current status, the name, performance data and the exit.

```text
[OK] Tutorial:
| 'tutorial'=;;
0
```

### Optional Performance Data

To make performance data optional on user input, we can now add another argument to our paramter list and update our check result object to use this argument

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check = New-IcingaCheck `
                -Name 'Tutorial';

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $Check -NoPerfData $NoPerfData -Compile)
}
```

Once we call the module with the `NoPerfData` argument, performance data is no longer printed

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial -NoPerfData; }
```

```text
[OK] Tutorial:
0
```

### Add Value to Check-Object

Now as the basic skeleton is ready, we can dive into the actual check object. In our example we will use a `random value`, but feel free to add any other related PowerShell value fetched by WMI, APIs or other components here.

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check = New-IcingaCheck `
                -Name 'Tutorial' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $Check -NoPerfData $NoPerfData -Compile)
}
```

By doing so, nothing will change from the plugin output in general, besides the performance data in case we wish to output them and the value the object is now holding.

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial }
```

```text
[OK] Tutorial: 79
| 'tutorial'=79;;
0
```

### Compare Value with Tresholds

Now as we are holding a value inside our check object, we can start to compare it with our `Warning` and `Critical` tresholds. There are a bunch of functions inside the check object avaialble for this which can be found in the [check object documentation](01-New-IcingaCheck.md).

For most plugins the generic approach will do just fine. This one will ensure we can use the Nagios/Icinga treshold syntax to compare values more dynamicly and add ranges support. (See also [Icinga Plugins](https://icinga.com/docs/windows/latest/plugins/doc/10-Icinga-Plugins/))

The two functions we will use for this are `WarnOutOfRange` and `CritOutOfRange`.

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check = New-IcingaCheck `
                -Name 'Tutorial' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Each compare function within our check object will return the
    # object itself, allowing us to write a nested call like below
    # to compare multiple values at once.
    # IMPORTANT: We have to output the last call either to Out-Null
    #            or store the result inside a variable, as the check
    #            object is otherwise written into our plugin output
    $Check.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $Check -NoPerfData $NoPerfData -Compile)
}
```

**NOTE:** It is very important to output the function calls either to `Out-Null` or assign a variable to store the content, as otherwise we will spam our check object into our plugin output

```powershell
$dump = $Check.WarnOutOfRange($Warning).CritOutOfRange($Critical);
```

As we have now added comparing functions to our plugin, we can execute the plugin again and check if everything works as intended

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial -Warning 20 -Critical 30 }
```

```text
[CRITICAL] Tutorial: Value "76" is greater than threshold "30"
| 'tutorial'=76;20;30
2
```

### Using Check Packages

Now it is time to combine multiple check objects into one check package. Our basic plugin works just fine, but maybe we wish to compare multiple values for multiple checks. To do so, we will create another `check object` and one `check package object`.

Dont forget to add the compare functions `WarnOutOfRange` and `CritOutOfRange` for the new `check object`!

Last but not least we will modify our `New-IcingaCheckResult` fuction to use the `check package` instead of our old `check object`

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check  = New-IcingaCheck `
                -Name 'Tutorial' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Add another check objects with a different name for identifying
    # which check is holding which value
    $Check2 = New-IcingaCheck `
                -Name 'Tutorial 2' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Each compare function within our check object will return the
    # object itself, allowing us to write a nested call like below
    # to compare multiple values at once.
    # IMPORTANT: We have to output the last call either to Out-Null
    #            or store the result inside a variable, as the check
    #            object is otherwise written into our plugin output
    $Check.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
    # Dont forget to add our comparison for the second check with
    # the identical tresholds. If you want to, you could compare
    # them to different arguments
    $Check2.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    # Now lets define a check package we can combine our checks into.
    # Check packages have names themself and provide a function to
    # add checks into. We can either add them directly during creation
    # or later
    $CheckPackage = New-IcingaCheckPackage `
                        -Name 'Tutorial Package' `
                        -Checks @(
                            $Check,
                            $Check2
                        );

    # Alternatively we can also call the method AddCheck
    # $CheckPackage.AddCheck($Check);
    # $CheckPackage.AddCheck($Check2);

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile)
}
```

If we now call our script plugin again, we will see two output for performance data

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial -Warning 20 -Critical 30 }
```

```test
[OK] Check package "Tutorial Package"
| 'tutorial'=63;20;30 'tutorial_2'=37;20;30
0
```

### Package Operators

As you see, the plugin output is `Ok` while clearly it should throw `Critical`. What we are missing is a comparing operator, telling the package how to count each assiged check. We have several operators on our hand:

* `-OperatorMin <number>` with `<number>` amount of checks require to be ok for the package to be ok
* `-OperatorMax <number>` with `<number>` amount of checks require to be ok for the package to be ok
* `-OperatorAnd` for all checks requiring to be ok for the package to be ok
* `-OperatorOr` for atleast one check requiring to be ok for the package to be ok
* `-OperatorNone` for all checks to be `not` ok for the package to be ok

You can only use one operator per check package, a combination is not possible.

On our example we will use the `-OperatorAnd` to ensure all checks have to be ok for the package to be ok

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check  = New-IcingaCheck `
                -Name 'Tutorial' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Add another check objects with a different name for identifying
    # which check is holding which value
    $Check2 = New-IcingaCheck `
                -Name 'Tutorial 2' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Each compare function within our check object will return the
    # object itself, allowing us to write a nested call like below
    # to compare multiple values at once.
    # IMPORTANT: We have to output the last call either to Out-Null
    #            or store the result inside a variable, as the check
    #            object is otherwise written into our plugin output
    $Check.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
    # Dont forget to add our comparison for the second check with
    # the identical tresholds. If you want to, you could compare
    # them to different arguments
    $Check2.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    # Now lets define a check package we can combine our checks into.
    # Check packages have names themself and provide a function to
    # add checks into. We can either add them directly during creation
    # or later
    $CheckPackage = New-IcingaCheckPackage `
                        -Name 'Tutorial Package' `
                        -Checks @(
                            $Check,
                            $Check2
                        ) `
                        -OperatorAnd;

    # Alternatively we can also call the method AddCheck
    # $CheckPackage.AddCheck($Check);
    # $CheckPackage.AddCheck($Check2);

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile)
}
```

Now lets see how the output changes

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial -Warning 20 -Critical 30 }
```

```text
[CRITICAL] Check package "Tutorial Package" - [CRITICAL] Tutorial, Tutorial 2
\_ [CRITICAL] Tutorial: Value "52" is greater than threshold "30"
\_ [CRITICAL] Tutorial 2: Value "60" is greater than threshold "30"
| 'tutorial'=52;20;30 'tutorial_2'=60;20;30
2
```

As you can see our package is now critical, outputting each check which is `not` Ok. In addition the functions will add

```text
[CRITICAL] Tutorial, Tutorial 2
```

inside the short plugin output to ensure we have a quick overview within Icinga Web 2, telling us which checks are failling.

### Increasing Verbosity

In case our checks are ok, they are not printed by default to keep the view as little as possible. We can test this by executing the plugin without tresholds

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial }
```

```text
[OK] Check package "Tutorial Package"
| 'tutorial'=63;; 'tutorial_2'=51;;
0
```

In case we want to make it configurable if every single `check object` and `check package` is printed, we can add a `Verbosity` flag. This will also introduce another method for the `params` of the module, as we will only allow certain input values for the `Verbosity` argument.

In addition, we will parse the new `$Verbosity` as argument to our `check package`

```powershell
function Invoke-IcingaCheckTutorial()
{
    # Create our arguments we can use to parese thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE,
        # Ensure only 0-2 values are allowed for Verbosity
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity     = 0
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check  = New-IcingaCheck `
                -Name 'Tutorial' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Add another check objects with a different name for identifying
    # which check is holding which value
    $Check2 = New-IcingaCheck `
                -Name 'Tutorial 2' `
                -Value (
                    Get-Random -Minimum 10 -Maximum 100
                );
    # Each compare function within our check object will return the
    # object itself, allowing us to write a nested call like below
    # to compare multiple values at once.
    # IMPORTANT: We have to output the last call either to Out-Null
    #            or store the result inside a variable, as the check
    #            object is otherwise written into our plugin output
    $Check.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
    # Dont forget to add our comparison for the second check with
    # the identical tresholds. If you want to, you could compare
    # them to different arguments
    $Check2.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

    # Now lets define a check package we can combine our checks into.
    # Check packages have names themself and provide a function to
    # add checks into. We can either add them directly during creation
    # or later
    $CheckPackage = New-IcingaCheckPackage `
                        -Name 'Tutorial Package' `
                        -Checks @(
                            $Check,
                            $Check2
                        ) `
                        -OperatorAnd `
                        -Verbose $Verbosity;

    # Alternatively we can also call the method AddCheck
    # $CheckPackage.AddCheck($Check);
    # $CheckPackage.AddCheck($Check2);

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile)
}
```

If we now exectue the plugin with `Verbosity` and the value `2`, every single check will be printed, even when the check itself is Ok

```powershell
powershell -C { Use-Icinga; Invoke-IcingaCheckTutorial -Verbosity 2 }
```

```text
[OK] Check package "Tutorial Package" (Match All)
\_ [OK] Tutorial: 70
\_ [OK] Tutorial 2: 36
| 'tutorial'=70;; 'tutorial_2'=36;;
0
```

The following `Verbose` options are available

* `0`: Default - only `not` Ok values will be printed
* `1`: Only `not` Ok values will be printed including package `operator` config
* `2`: Everything will be printed

### More Complex Checks

We will not provide an example in this guide, but we would like to add that this is not the final complexity level of plugins. Each `check package` for example could contain multiple `check packages` with `checks` and even more `check packages`.

You simply have to ensure you are adding `checks` and `check packages` correctly into each object and parse your primary `check package` to the `check result Cmdlet`. The Framework will then deal with the entire operation and calculation itself

### Plugin Providers

In addition we would like you keep the plugin and possible data providers separated. If you for example write plugins for your application monitoring and you require different functions to collect these information, the guided way is to separate the collector functions from the plugin itself.

The file structure will look like this

```text
plugin folder
  |_ plugin.psm1
  |_ provider_folder
     |_ your_plugin_provider.psm1
```

This will ensure these functions can be called separately from the plugin itself and make re-using them a lot easier.

### Icinga Configuration

Now as we are done with writing our plugin, it is time to test it inside Icinga 2. Instead of having to write an `Icinga Director` command configuration yourself, we can use an integrated Framework Cmdlet to generate a `Basket` file for us which can be imorted into the `Icinga Director`.

```powershell
Get-IcingaCheckCommandConfig -CheckName 'Invoke-IcingaCheckTutorial' -OutDirectory 'C:\users\public';
```

```text
The following commands have been exported:
- 'Invoke-IcingaCheckTutorial'
JSON export created in 'C:\users\public\PowerShell_CheckCommands_03-31-2020-17-34-5367.json'
```

This is the reason why it is `mandatory` to place plugin Cmdlets within the `Invoke-IcingaCheck` "namespace". Calling `Get-IcingaCheckCommandConfig` without the `CheckName` argument will automatically lookup every command with this naming schema and export all of them inside the `Basket` file.

### General Guidelines

To ensure the later import into the `Icinga Director` and usage within Icinga 2 is as easy as possible, it is recommended to write a proper plugin documentation which is understood by the `Get-Help` Cmdlet of Windows. By doing so, arguments are described directly inside the `Icinga Director`.

Another important note are correct `data types` for values. Each `data type` is translated properly into `Icinga Director` language, resulting in the following behaviour:

* `[string]` will be translated to text values on check input fields
* `[int]` will be translated to numeric values on check input fields
* `[bool]` will be translated to yes/no values on check input fields
* `[switch]` will be translated to yes/no values on check input fields
* `[array]` will be translated to array values on check input fields

By using the `ValidateSet` feature of PowerShell (as we did for our `Verbosity`) we will automatically generate a `custom variable` as `datalist`, only allowing the valid input values in a `drop down list`
