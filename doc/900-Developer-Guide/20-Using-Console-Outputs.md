# Developer Guide: Using Console Outputs

The Icinga PowerShell Framework provides severals Cmdlets to write output into the PowerShell console, ensuring that not only a severity is added but also making it easier to dump object content into the message. In addition these functions are disabled once being called while the Framework is running as background daemon, to ensure the console is not spammed with useless information the user wont see anyway.

The only limitation is that the entire font color can not be changed by using these methods.

## Build-In String Formatting

There are many different ways in PowerShell on how to format a string and add object values to them. Some will look nicer than others and by default we mostly use `[string]::Format()` for this task, as it provides a much better readability.

Following this guideline, a simple output to console might look like this:

```powershell
Write-Host ([string]::Format('Hello World counter: {0}', 10));
```

Even while being correct, it is now not as easy anymore to read the line. Of course we can do some formatting to make it readable a lot better:

```powershell
Write-Host (
    [string]::Format(
        'Hello World counter: {0}',
        10
    )
);
```

Now the output is much more readbable, but managing this syntax through the entire code structure will possibly affect the entire code again.

The Icinga PowerShell Framework is for this reason providing Cmdlets which will handle the console outputs and the formatting for the user. To simply write plain text to the console, we can do so by using `Write-IcingaConsolePlain` including an `array` of objects to add:

```powershell
Write-IcingaConsolePlain -Message 'Hello World counter: {0}' -Objects 10;
```

The usage of the `{}` including the numeric input and how they are parsed is identical to `[string]::Format()`. `-Objects` is able to hold an array of elements which will replace the `{x}` placeholders, depending on the index of the element.

```powershell
Write-IcingaConsolePlain -Message 'Hello World counter: {0}{1}Maybe adding some newlines as well?' -Objects 10, (New-IcingaNewLine);
```

## Plain Output Without Severity

To write simple content like plugin output, wizard questions or different generic content you can use `Write-IcingaConsolePlain`. This will print content similar to `Write-Host`, but allowing the usage of the `-Objects` argument for easier text formatting:

```powershell
Write-IcingaConsolePlain -Message 'This is a generic output to console: {0}' -Objects (Get-Random);
```

> This is a generic output to console: 802189320

## Output With Severity

To add content to the console inlcuding a severity for better understanding and readability, there are several Cmdlets available following the same structure as the above mentioned. In addition they will how ever print a colored severity in `[]` before the actual message.

### Write-IcingaConsoleNotice

A notice is a simple notification about certain tasks which are processed and to inform the user about something. They will add a `Notice` message in `green` color before the output:

```powershell
Write-IcingaConsoleNotice -Message 'This is a notice output to console: {0}' -Objects (Get-Random);
```

> [<span style="color:green">Notice</span>]: This is a notice output to console: 292276902

### Write-IcingaConsoleWarning

A warning is in general not bad, should how ever inform the user about a possible flaw in configuration, additional required steps or that something did not went as expected. They will add a `Warning` message in `yellow` color before the output:

```powershell
Write-IcingaConsoleWarning -Message 'This is a warning output to console: {0}' -Objects (Get-Random);
```

> [<span style="color:yellow">Warning</span>]: This is a warning output to console: 1107808784

### Write-IcingaConsoleError

Errors indicate that something went wrong during certain tasks and possibly the intended action did not fully complete properly. They will add a `Error` message in `red` color before the output:

```powershell
Write-IcingaConsoleError -Message 'This is a error output to console: {0}' -Objects (Get-Random);
```

> [<span style="color:red">Error</span>]: This is a error output to console: 93122235

### Write-IcingaConsoleDebug

Debug prints are in general designed for developers or while troubleshooting certain issues. They will add a `Debug` message in `blue` color before the message:

```powershell
Write-IcingaConsoleDebug -Message 'This is a debug output to console: {0}' -Objects (Get-Random);
```

> [<span style="color:blue">Debug</span>]: This is a debug output to console: 1197035604

**Note:** Debug messages will only be printed if the `debug mode` of the Icinga PowerShell Framework is enabled. To enable the debug mode, you can use `Enable-IcingaFrameworkDebugMode` and to disable it `Disable-IcingaFrameworkDebugMode`. To check if the mode is enabled or disabled you can use `Get-IcingaFrameworkDebugMode`.
