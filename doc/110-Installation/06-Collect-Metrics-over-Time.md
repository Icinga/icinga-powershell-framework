# Collect Metrics over Time - Installation

Icinga for Windows provides the functionality directly build into the Icinga PowerShell Framework, to execute checks internally in defined time ranges and collect and store performance metrics from them.

Collected metrics are then, based on your configuration, added to an actual check execution from Icinga and added as performance data label to your check. By using the `-ThresholdInterval` argument of the plugins, you can also use the checks thresholds to compare them against the collected metrics instead of the current value.

## Requirements

For this feature to work, you will require the Icinga PowerShell Service being installed and know how to [manage background daemons](05-Background-Daemons.md).

## Register the Background Daemon

The Icinga PowerShell Framework ships with a build-in daemon, which allows to queue service checks internally to collect metrics. The Cmdlet for this daemon is `Start-IcingaServiceCheckDaemon`.

**Note:** Please note this daemon *only* collects the performance metrics and is not meant to actually apply monitoring tasks.

At first, we need to register this daemon:

```powershell
Register-IcingaBackgroundDaemon `
    -Command 'Start-IcingaServiceCheckDaemon';
```

## Manage Service Checks

Once the daemon is registered, you can start configuring plugins which are frequently executed and the performance metrics collected. The intervall of execution including the time interval of which metrics are stored, can be configured individually.

**Note:** It is **not** supported to register the same plugin multiple times with different arguments. In case you want to collect several, different performance counters with `Invoke-IcingaCheckPerfCounter` for example, you will have to add all counters to one plugin call.

### Register Service Checks

In order to add service check to our daemon, we can use `Register-IcingaServiceCheck`.

| Arguments    | Type      | Description |
| ---          | ---       | ---         |
| CheckCommand | String    | The plugin you want to execute inside the daemon |
| Arguments    | Hashtable | Plugin arguments which are added to the internal check |
| Interval     | Integer   | The time interval in seconds on how often the check is executed |
| TimeIndexes  | Array     | A list of Integer time indexes, for which time frames metrics should be collected. Always ensure to add the proper time unit to the values: s, m, d, M, y. A value without a unit always means seconds by default |

#### Examples

##### Register CPU Plugin

We will register our CPU plugin to run every 30 seconds and collect the average metrics for 1, 3, 5 and 15 minutes:

```powershell
Register-IcingaServiceCheck `
    -CheckCommand 'Invoke-IcingaCheckCPU' `
    -Interval 30 `
    -TimeIndexes 1m, 3m, 5m, 15m;
```

**Note:** The handling for `-TimeIndexes` has changed with the latest Icinga for Windows version, as you now have to specify the unit for the time value to build the average for. This enables more flexible support to collect averages for hours or days as example.

##### Register Partition Space Plugin

Lets register our used partition space plugin, to run every 15 seconds, collect the average metrics for 1m, 3m,5m, 20m and 1h and only include drive C:

```powershell
Register-IcingaServiceCheck `
    -CheckCommand 'Invoke-IcingaCheckUsedPartitionSpace' `
    -Arguments @{
        '-Include' = 'C';
    } `
    -Interval 15 `
    -TimeIndexes 1m, 3m, 5m, 20m, 1h;
```

##### Register Performance Counter Plugin with Multi-Values

Finally lets register our performance counter plugin to run every 30 seconds and collect average metrics for multiple, independent counters for 1, 3, 5, 10, 15 and 20 minutes:

```powershell
Register-IcingaServiceCheck `
    -CheckCommand 'Invoke-IcingaCheckPerfCounter' `
    -Arguments @{
        '-PerfCounter' = @(
            '\Processor(*)\% Processor Time',
            '\Memory\% committed bytes in use',
            '\Memory\Available Bytes'
        );
    } `
    -Interval 15 `
    -TimeIndexes 1m, 3m, 5m, 10m, 15m, 20m;
```

### Show Registered Service Checks

To fetch a list of currently registered service checks, you can run the following command:

```powershell
Show-IcingaRegisteredServiceChecks;
```

```powershell
List of configured background service checks on this system.
=> https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/

Invoke-IcingaCheckPerfCounter
-----------
Arguments    => -PerfCounter '\Processor(*)\% Processor Time', '\Memory\% committed bytes in use', '\Memory\Available Bytes'
CheckCommand => Invoke-IcingaCheckPerfCounter
Id           => 1332191811682909517982372151451071972043015735175
Interval     => 15
TimeIndexes  => 1m, 3m, 5m, 10m, 15m, 20m

```

You will then receive a list of all configured plugins, including their configuration and `service id`.

### Unregister Service Checks

To unregister a service check from the daemon, you will require the `service id` of the registered service which you can get with `Show-IcingaRegisteredServiceChecks`. You can then use the id to unregister the service:

```powershell
Unregister-IcingaServiceCheck -ServiceId 1332191811682909517982372151451071972043015735175;
```

## Restart Icinga PowerShell Daemon

Finally to apply all your changes, we have to restart the Icinga for Windows Powershell Daemon

```powershell
Restart-IcingaWindowsService;
```
