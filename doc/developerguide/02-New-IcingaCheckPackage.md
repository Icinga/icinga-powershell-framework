# Developer Guide: New-IcingaCheckPackage

Below you will find a list of functions and detailed descriptions including use cases for Cmdlets and features the PowerShell Framework provides.

| Type | Return Value | Description |
| --- | --- | --- |
| Cmdlet | PowerShell Object | Check Object containing other check objects |

The `IcingaCheckPackage` is the first step to take to write more advanced checks. A `IcingaCheckPackage` offers the possibility to build a check containing varius `IcingaChecks`. Just like the `IcingaCheck`, the `IcingaCheckPackage` also provides a bunch of internal commands within the PowerShell Object to analyse a value and get the Icinga result `Ok`, `Warning`, `Critical` including performance metrics. In this case the result is based on the result of the logical connection between added `IcingaChecks` within the `IcingaCheckPackage`

It will be used like in this example:


```powershell
$IcingaPackage = New-IcingaCheckPackage -Name 'My Package' -OperatorAnd;
```

## Arguments

| Argument     | Input  | Mandatory | Description |
| ---          | ---    | ---       | ---         |
| Name         | String    |  *        | The unique name of each package within a plugin. Will be displayed in the check output.  |
| OperatorAnd  | Switch    |           | Logical relation of the check within the package becomes an AND |
| OperatorOr   | Switch    |           | Logical relation of the check within the package becomes an Or |
| OperatorNone | Switch    |           | - |
| OperatorMin  | Int       |           | - |
| OperatorMax  | Int       |           | - |
| Checks       | Array     |           | Array of checks to be added to the check package |
| Verbose      | int       |           | Defines the level of output detail from 0 lowest to 3 highest detail |
| Hidden       | Switch    |           | If set, the check package doesn't generate output |
