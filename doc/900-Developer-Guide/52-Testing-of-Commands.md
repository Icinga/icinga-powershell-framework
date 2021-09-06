# Developer Guide: Testing of Commands

Actively developing new code for the Framework will result in core files to be changed or new functionality added. To load the Framework we use in general `Use-Icinga`, which does how ever not cover changes we made afterwards. To keep track of the changes for new features or while testing something, we always have to open a new PowerShell instance.

To make things more usable, we can of course run a PowerShell command directly from our shell:

```powershell
powershell -C { Use-Icinga; <# your code #> }
```

While this is straight forward and easy to use, the idea is to make this way simpler.

## Invoke-IcingaCommand or simply icinga

Instead of having to write a long command for testing, you can use the newly introduced Cmdlet `Invoke-IcingaCommand` with PowerShell Framework 1.2.0. To make it even easier, we created an alias for this: `icinga`

To test new commands, features or to simply troubleshoot you can now simply type `icinga` followed by `{ }` containing your code:

```powershell
icinga { <# your code #> }
```

One easy example is to simply print console output;

```powershell
icinga { Write-IcingaConsoleError 'Hello from Icinga' }
```

```text
[Error]: Hello from Icinga
```

The command will load the entire Framework and all components and output the result of your code.

## Rebuilding Framework Cache

Starting with Icinga for Windows v1.6.0, a caching is natively implement to speed-up the loading of the Framework. In case modifications are done on the Framework itself, you can use the `icinga` alias together with the argument `-RebuildCache` and your code snippet to rebuild the cache and run your code within the updated state.

```powershell
icinga { Write-IcingaConsoleError 'Hello from Icinga' } -RebuildCache
```

## Improved Shell handling

In addition to above mentioned example, you can not only execute code snippets but also start a new PowerShell with the entire Framework loaded. The benefit of this is, that while mostly an `exit` should be handled, it might still cause your shell to close. With the `icinga` command, you will only close an additional shell and keep your own shell open:

```powershell
C:\Users> icinga
icinga>
```

Now you can type in your commands as you would on any other PowerShell - how ever, this is a new instance so in case we close it, we still have our shell open:

```powershell
icinga> Exit-IcingaThrowException -Force -CustomMessage 'Force Exit of our Shell with an exception';
[UNKNOWN]: Icinga Unhandled Error was thrown: Unhandled Exception: Force Exit of our Shell with an exception

Unhandled exception occured:
```

Instead of our own shell closing, we still have our previous one open and can start another shell by using `icinga` with the entire Framework loaded.

This also works for code we directly invoke to the `icinga` alias:

```powershell
icinga { Exit-IcingaThrowException -Force -CustomMessage 'Force Exit of our Shell with an exception'; }
```

```text
[UNKNOWN]: Icinga Unhandled Error was thrown: Unhandled Exception: Force Exit of our Shell with an exception

Unhandled exception occured:
```
