# Read Icinga Agent Log/DebugLog

The Icinga PowerShell Framework is shipping wish a bunch of Cmdlets to manage the Icinga Agent in a very easy way. This includes reading the Icinga Agent log/debug log file.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `icinga -Shell`

## Read the default Icinga Agent log file

Icinga is writing current events by default in an own log file. The default location is `C:\ProgramData\icinga2\var\log\icinga2\icinga2.log`. To make it easier to read the log from the command line, we can use the `Read-IcingaAgentLogFile` Cmdlet which will update the command line for any new log line which is written by the Icinga Agent during the usage of the command:

```powershell
Read-IcingaAgentLogFile;
```

```text
[2020-08-12 15:44:20 +0200] information/ConfigObject: Dumping program state to file 'C:\ProgramData\icinga2\var\lib\icinga2/icinga2.state'
[2020-08-12 15:49:20 +0200] information/ConfigObject: Dumping program state to file 'C:\ProgramData\icinga2\var\lib\icinga2/icinga2.state'
[2020-08-12 15:50:08 +0200] information/Application: Received request to shut down.
[2020-08-12 15:50:08 +0200] information/Application: Shutting down...
[2020-08-12 15:50:42 +0200] information/FileLogger: 'main-log' started.
[2020-08-12 15:50:42 +0200] information/ConfigItem: Activated all objects.
...
```

## Read Icinga Agent debug log

As for the default log file, the Icinga Agent also writes more detailed entries into an own debug log. This has to be enabled as [Icinga Agent Feature](04-Manage-Icinga-Agent-Features.md) with the name `debuglog`. Once enabled, you can locate it on the default location `C:\ProgramData\icinga2\var\log\icinga2\debug.log` and access it with the Cmdlet `Read-IcingaAgentDebugLogFile`:

```powershell
Read-IcingaAgentDebugLogFile;
```

```text
[2020-08-12 16:36:53 +0200] information/FileLogger: 'debug-file' started.
[2020-08-12 16:36:53 +0200] information/FileLogger: 'main-log' started.
[2020-08-12 16:36:53 +0200] information/ConfigItem: Activated all objects.
[2020-08-12 16:36:53 +0200] notice/WorkQueue: Stopped WorkQueue threads for 'DaemonCommand::Run'
[2020-08-12 16:36:53 +0200] notice/ApiListener: Updating object authority for local objects.
[2020-08-12 16:36:53 +0200] debug/IcingaApplication: In IcingaApplication::Main()
...
```
