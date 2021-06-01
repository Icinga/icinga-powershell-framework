# Analyse EventLog

With Icinga for Windows v1.5.0, we added a simple Cmdlet, allowing you to analyse your EventLog, which might help you to configure your [Invoke-IcingaCheckEventlog](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/plugins/06-Invoke-IcingaCheckEventlog/) plugin and to increase performance. The command is called `Show-IcingaEventLogAnalysis`

## Analyse Specific Logs

Like the [Invoke-IcingaCheckEventlog](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/plugins/06-Invoke-IcingaCheckEventlog/), you have to specify an EventLog to analyse by using the argument `-LogName`.
The EventLog analyser will then load all events present in this log, and analyse the following:

* Total amount of logs
* Average logs per day/hour/minute
* Oldes and newest logs

Example:

```powershell
icinga> Show-IcingaEventLogAnalysis -LogName Application;
[Notice]: Analysing EventLog "Application"...
[Notice]: Logging Mode: Circular
[Notice]: Maximum Size: 0.02 GB
[Notice]: Current Entries: 62036
[Notice]: Average Logs per Day: 8863
[Notice]: Average Logs per Hour: 447
[Notice]: Average Logs per Minute: 15
[Notice]: Maximum Logs per Day: 26143
[Notice]: Maximum Logs per Hour: 1724
[Notice]: Maximum Logs per Minute: 239
[Notice]: Newest entry timestamp: 2021-06-02 09:06:42
[Notice]: Oldest entry timestamp: 2021-05-27 15:11:53
[Notice]: Analysing Time: 11.19s
```

Based on these information, you can improve the EventLog check on this system even more, as we added the `-MaxEntries` argument to [Invoke-IcingaCheckEventlog](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/plugins/06-Invoke-IcingaCheckEventlog/), which will limit the amount of logs loaded for the check. The value currently defaults to `40000`.

## Understanding The Data

As we now run the analyse command for the log we want to monitor, we can have a look on the data. The idea behind this, is to understand on how many log entries are present on a specific time range, as this will help us to determine if we require to load the default of `40000` events or can reduce this number and therefor the execution time of the plugin.

Lets assume we are going to run our EventLog check every `5 minutes`. The average log amount per Minute is `15`, while the maximum ever occurred is `239` per minute.
We will always recommend to use the maximum log amount as base calculation. In addition, once you did the calculation double the value to ensure you always have enough buffer left in case more entries are logged.

As we can simply use the maximum minute value in our example, the calculation would be this:

```text
239 maximum logs per minute * 5 minute check interval * 2 = 2390 logs
```

We can now use this value, to improve the EventLog check:

```powershell
Invoke-IcingaCheckEventlog -LogName Application -Warning 5 -IncludeEntryType Warning -Before 5m -MaxEntries 2390;

[OK] EventLog: 1 Ok
```
