# Developer Guide: New-IcingaCheck

Below you will find a list of functions and detailed descriptions including use cases for Cmdlets and features the PowerShell Framework provides.

| Type | Return Value | Description |
| --- | --- | --- |
| Cmdlet | PowerShell Object | Check Object containing values and handling warning / error states |

The `IcingaCheck` is the basic start point for determining on how a certain value is performing. Checks will provide a bunch of internal commands within the PowerShell Object to analyse a value and get the Icinga result `Ok`, `Warning`, `Critical` including performance metrics.

Checks are always used wihtin Check Plugins to have a standardised method for properly handling the input.

It will be used like in this example:

```powershell
$IcingaCheck = New-IcingaCheck -Name 'My Check' -Value 25 -Unit '%';
```

You will have to provide a `Name` for each check which **must** be unique within each Check Plugin. This will make it easier to differentiate between checks for results. The `Value` is mandatory as this will be the base for each single check to fetch the actual status.

For performance metrics you can provide a `Unit` to ensure your graphing is displaying values as the should be

## Arguments

| Argument     | Input  | Mandatory | Description |
| ---          | ---    | ---       | ---         |
| Name         | String    |  *        | The unique name of each check within a plugin. Will be display in the check output.  |
| Value        | Object    | *         | The value all comparison is done with. In general this should be a `Numeric` or `String` value |
| Unit         | Units     |           | Specify the unit for a value to display graph properly |
| Minimum      | String    |           | The minimum value which is displayed on your graphs |
| Maximum      | String    |           | The maximum value which is displayed on your graphs |
| ObjectExists | Bool      |           | If you are using values coming from objects, like Services, you can use this argument to determin if the object itself exist or not. In case it doesn't, you will receive a proper output on the check result |
| Translation  | Hashtable |           | In case you want to map values to certain descriptions, you can place a hashtable at this argument which will then map the value to the description on the check result. For example this would apply to service running states |
| NoPerfData   | Switch    |           | Disables Performance Data output for this check object |

## Units

| Unit | Name         | Description                                     |
| ---  | ---          | ---                                             |
| %    | Percentage   | The input value is a percentual value           |
| s    | Seconds      | The input is indicated as time seconds          |
| ms   | Milliseconds | The input is indicated as time in milliseconds  |
| us   | Microseconds | The input is indicated as time in microseconds  |
| B    | Bytes        | The input is indicated as quantity in bytes     |
| KB   | Kilobytes    | The input is indicated as quantity in kilobytes |
| MB   | Megabytes    | The input is indicated as quantity in megabytes |
| GB   | Gigabytes    | The input is indicated as quantity in gigabytes |
| TB   | Terabytes    | The input is indicated as quantity in terabytes |
| c    | Counter      | A continues counter increasing values over time |

## Object Functions

The `New-IcingaCheck` Cmdlet will return a custom PowerShell object which provides a bunch of functions to easier manage the handling of the output.

Please note that most of the listed functions below will return itself as object, which means you will have to drop the content with `| Out-Null` after calling them.

### Wrong

```powershell
$IcingaCheck.WarnOutOfRange(10)
```

### Correct

```powershell
$IcingaCheck.WarnOutOfRange(10) | Out-Null
```

### Nested functions

An example for a nested function call could be this

```powershell
$IcingaCheck.WarnOutOfRange(10).CritOutOfRange(20) | Out-Null
```

### Functions

For most parts it is recommended to use the `OutOfRange` functions for `warning` and `critical` checks as the user is able to dynamicly set the range with the arguments of the plugins. For string values the `Like` and `Match` functions should be used.

#### Recommended functions

| Function        | Parameters         | Description                                     | Example |
| ---             | ---                | ---                                             | ---     |
| WarnOutOfRange | Warning | This will make use of the Icinga Threshhold handling, like `10`, `~:10`, `@10:20` and properly return the correct ok / warning state of the plugin | $IcingaCheck.WarnOutOfRange(10) | Out-Null |
| CritOutOfRange | Critial | This will make use of the Icinga Threshhold handling, like `10`, `~:10`, `@10:20` and properly return the correct ok / critical state of the plugin | $IcingaCheck.CritOutOfRange(10) | Out-Null |
| WarnIfLike | Warning | Will return warning in case the input is `like` the value | $IcingaCheck.WarnIfLike('\*running\*') |
| WarnIfNotLike | Warning | Will return warning in case the input is `not like` the value | $IcingaCheck.WarnIfNotLike('\*running\*') |
| WarnIfMatch | Warning | Will return warning in case the input is `matching` the value | $IcingaCheck.WarnIfMatch('running') |
| WarnIfNotMatch | Warning | Will return warning in case the input is `not matching` the value | $IcingaCheck.WarnIfNotMatch('running') |
| CritIfLike | Critial | Will return critical in case the input is `like` the value | $IcingaCheck.CritIfLike('\*running\*') |
| CritIfNotLike | Critial | Will return critical in case the input is `not like` the value | $IcingaCheck.CritIfNotLike('\*running\*') |
| CritIfMatch | Critial | Will return critical in case the input is `matching` the value | $IcingaCheck.CritIfMatch('running') |
| CritIfNotMatch | Critial | Will return critical in case the input is `not matching` the value | $IcingaCheck.CritIfNotMatch('running') |

#### All other functions

| Function        | Parameters         | Description                                     | Example |
| ---             | ---                | ---                                             | ---     |
| WarnIfBetweenAndEqual | Min, Max | Will return warning in case the input is `between or equal` the `min` and `max` value | $IcingaCheck.WarnIfBetweenAndEqual(10, 20) |
| WarnIfBetween | Min, Max | Will return warning in case the input is between the `min` and `max` value | $IcingaCheck.WarnIfBetween(10, 20) |
| WarnIfLowerThan | Warning | Will return warning in case the input is `lower` than the value | $IcingaCheck.WarnIfLowerThan(10) |
| WarnIfLowerEqualThan | Warning | Will return warning in case the input is `lower or equal` than the value | $IcingaCheck.WarnIfLowerEqualThan(10) |
| WarnIfGreaterThan | Warning | Will return warning in case the input is `greater` than the value | $IcingaCheck.WarnIfGreaterThan(10) |
| WarnIfGreaterEqualThan | Warning | Will return warning in case the input is `greater or equal` than the value | $IcingaCheck.WarnIfGreaterEqualThan(10) |
| CritIfBetweenAndEqual | Min, Max | Will return critical in case the input is `between or equal` the `min` and `max` value | $IcingaCheck.CritIfBetweenAndEqual(10, 20) |
| CritIfBetween | Min, Max | Will return critical in case the input is between the `min` and `max` value | $IcingaCheck.CritIfBetween(10, 20) |
| CritIfLowerThan | Critial | Will return critical in case the input is `lower` than the value | $IcingaCheck.CritIfLowerThan(10) |
| CritIfLowerEqualThan | Critial | Will return critical in case the input is `lower or equal` than the value | $IcingaCheck.CritIfLowerEqualThan(10) |
| CritIfGreaterThan | Critial | Will return critical in case the input is `greater` than the value | $IcingaCheck.CritIfGreaterThan(10) |
| CritIfGreaterEqualThan | Critial | Will return critical in case the input is `greater or equal` than the value | $IcingaCheck.CritIfGreaterEqualThan(10) |

### Examples

#### Example 1

Simple check item which will return `critical` as the value is `37` and we want throw `warning` above `20` and `critical` above `35`

```powershell
$IcingaCheck = New-IcingaCheck -Name 'My Check' -Value 37 -Unit '%';
$IcingaCheck.WarnOutOfRange(20).CritOutOfRange(35) | Out-Null;
```

#### Example 2

Check item with `ObjectExists` argument including `Translation`. As the input status `4` is an integer, we will convert the status to the string value `Running` and use the `Translation` argument to properly print the output in human readable strings

```powershell
$Service         = Get-IcingaServices -Service 'icinga2';
$ConvertedStatus = ConvertTo-ServiceStatusCode -Status 4;
$StatusRaw       = $Service.Values.configuration.Status.raw;

$IcingaCheck = New-IcingaCheck -Name 'Icinga 2 Service' -Value $StatusRaw -ObjectExists $Service -Translation $ProviderEnums.ServiceStatusName;
$IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;
```

Output after parsed into `New-IcingaCheckResult`

```text
[CRITICAL]: Icinga 2 Service Stopped is not matching Running
```
