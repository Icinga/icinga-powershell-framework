Register Background Service Checks
===

Once the PowerShell Framework is [installed as service](01-Install-Service.md) and you enabled the `Start-IcingaServiceCheckDaemon` daemon by [registering it](02-Register-Daemons.md), you are free to configure service checks which are frequently executed on a custom time period.

Register Service Checks
---

Registering a service check will execute them frequently on a custom defined time. To do so you will have to register the check plugin you wish you collect metrics over time and add a execution time intervall including time indexes for which averages should be calculcated for.

As example we want to frequently collect our `CPU load` values with an `check interval of 30 seconds` and calculate `averages for 1m, 3m, 5m, and 15m`.

```powershell
Register-IcingaServiceCheck -CheckCommand 'Invoke-IcingaCheckCPU' -Interval 30 -TimeIndexes 1, 3, 5, 15;
```

Once you registered a service check, you will have to restart the PowerShell service

```powershell
Restart-IcingaWindowsService;
```

As collected metrics are written to disk as well, a restart will not flush previous data but load it again. A quick service restart will not cause missing data points.

Once the service check is executed from the background daemon, it will add additional output to your regular check execution from Icinga 2. If we execute our `Invoke-IcingaCheckCPU` now again, we will see additional metrics based on our configuration

```powershell
[OK] Check package "CPU Load"
| 'core_0_15'=1.17%;;;0;100 'core_0_3'=1.12%;;;0;100 'core_0_5'=1.65%;;;0;100 'core_0_1'=1.36%;;;0;100 'core_0'=0.19%;;;0;100 'core_1_1'=0.86%;;;0;100 'core_1_15'=4.59%;;;0;100 'core_1_5'=5.28%;;;0;100 'core_1_3'=1.15%;;;0;100 'core_total_5'=5.2%;;;0;100 'core_total_15'=4.32%;;;0;100 'core_total_1'=3.41%;;;0;100 'core_total_3'=3.79%;;;0;100 'core_total'=1.85%;;;0;100
```

As you can see, each time index we added for the `TimeIndexes` argument is added as separat metric to our performance output. The calculation is done by all collected values over the execution period.

List Service Checks
---

To list all registered service checks you can simply use

```powershell
Show-IcingaRegisteredServiceChecks;
```

This will print a detailed list of all checks and their configuration

```powershell
Service Id: 5275219864641021224811420224776891459631192206

Name                           Value
----                           -----
CheckCommand                   Invoke-IcingaCheckCPU
Interval                       30
Arguments
Id                             5275219864641021224811420224776891459631192206
TimeIndexes                    {1, 3, 5, 15}
```

Modify Service Checks
---

To modify service checks you can simply use the `Register-IcingaServiceCheck` command again with the identical check command, but overwritting interval and time indexes for example

```powershell
Register-IcingaServiceCheck -CheckCommand 'Invoke-IcingaCheckCPU' -Interval 60 -TimeIndexes 1, 3, 5, 15, 20;
```

Once you modified a service check, you will have to restart the PowerShell service

```powershell
Restart-IcingaWindowsService;
```

Unregister Service Checks
---

If you wish to remove a service check from the daemon, you can simply unregister it with the `id` displayed on the `Show-IcingaRegisteredServiceChecks` Cmdlet

```powershell
Unregister-IcingaServiceCheck -ServiceId 5275219864641021224811420224776891459631192206;
```

Once you removed a service check, you will have to restart the PowerShell service

```powershell
Restart-IcingaWindowsService;
```
