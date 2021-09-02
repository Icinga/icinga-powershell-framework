# Developer Guide: New-IcingaCheckResult

Below you will find a list of functions and detailed descriptions including use cases for Cmdlets and features the PowerShell Framework provides.

| Type | Return Value | Description |
| --- | --- | --- |
| Cmdlet | Integer | Compiles [Icinga Check](01-New-IcingaCheck.md)/[Check Package](02-New-IcingaCheckPackage.md) objects for valid Icinga Plugin output including performance data and returns the Icinga exit code as Integer |

The `IcingaCheckResult` is the final step to finalyse a Icinga Plugin with the Powershell Framework. The checkresult Cmdlet will process either an [Icinga Check](01-New-IcingaCheck.md) or [Check Package](02-New-IcingaCheckPackage.md) object and `compile` the stored details within to write the plugin output, performance data and return the exit code for Icinga as integer.

It will be used like in this example:

```powershell
return New-IcingaCheckresult -Check $MyCheckObject -Compile;
```

## Arguments

| Argument     | Input    | Mandatory | Description |
| ---          | ---      | ---       | ---         |
| Check        | PSObject |  *        | [Icinga Check](01-New-IcingaCheck.md) or [Check Package](02-New-IcingaCheckPackage.md) object  |
| NoPerfData  | Bool    |           | Bool value with `true` or `false` to print performance metrics for the plugin or to drop them |
| Compile   | Switch    |           | Will directly compile the checkresult, print the output to console and return the exit code as Integer |

### Examples

Please note that within the plugin output on console you will see a number at the end, which is the actual exit code of the plugin which is returned. If you are calling `Cmdlets` from within Icinga, you can simply use `exit` for the plugin call with PowerShell to tell Icinga the correct status.

```powershell
exit Invoke-IcingaCheckCPU;
```

#### Simple Check Output

```powershell
$IcingaCheck = New-IcingaCheck -Name 'My Check 1' -Value 37 -Unit '%';
$IcingaCheck.WarnOutOfRange(20).CritOutOfRange(35) | Out-Null;

return New-IcingaCheckresult -Check $IcingaCheck -Compile;
```

```text
[CRITICAL] My Check 1: Value "37%" is greater than threshold "35%"
| 'my_check_1'=37%;20;35;0;100
2
```

#### Simple Check Output without PerfData

```powershell
$IcingaCheck = New-IcingaCheck -Name 'My Check 1' -Value 37 -Unit '%';
$IcingaCheck.WarnOutOfRange(20).CritOutOfRange(35) | Out-Null;

return New-IcingaCheckresult -Check $IcingaCheck -NoPerfData $TRUE -Compile;
```

```text
[CRITICAL] My Check 1: Value "37%" is greater than threshold "35%"
2
```

#### Checkresult with check package

```powershell
$IcingaCheck1 = New-IcingaCheck -Name 'My Check 1' -Value 37 -Unit '%';
$IcingaCheck1.WarnOutOfRange(20).CritOutOfRange(35) | Out-Null;

$IcingaCheck2 = New-IcingaCheck -Name 'My Check 2' -Value 18 -Unit '%';
$IcingaCheck2.WarnOutOfRange(20).CritOutOfRange(35) | Out-Null;

$IcingaPackage = New-IcingaCheckPackage -Name 'My Package' -OperatorAnd;
$IcingaPackage.AddCheck($IcingaCheck1);
$IcingaPackage.AddCheck($IcingaCheck2);

return New-IcingaCheckresult -Check $IcingaPackage -Compile;
```

```text
[CRITICAL] Check package "My Package" - [CRITICAL] My Check 1
\_ [CRITICAL] My Check 1: Value "37%" is greater than threshold "35%"
| 'my_check_1'=37%;20;35;0;100 'my_check_2'=18%;20;35;0;100
2
```
