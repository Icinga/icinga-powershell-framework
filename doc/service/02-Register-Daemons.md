Register Background Daemons
===

One huge advantage of the entire PowerShell Framework for Icinga is to run the PowerShell environment as background service. Once you [installed the service](01-Install-Service.md) you can simply register functions which are executed.

Register Daemon
---

To register daemons which are executed on the backkground daemon, you can use the build in command `Register-IcingaBackgroundDaemon`. An example would be to enable the frequent service check daemon which ships with this framework

```powershell
Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
```

The `Start-IcingaServiceCheckDaemon` is a directly integrated PowerShell function which will itself start an own thread for executing regular service checks which have been registered.

Once you made changes, please remember to restart the PowerShell Service

```powershell
Restart-IcingaService 'icingapowershell';
```

List Enabled Daemons
---

To list all registered background daemons you can use a build-in command for this

```powershell
Get-IcingaBackgroundDaemons;
```

Once executed you will receive a list of all daemons which are started

```powershell
Name                           Value
----                           -----
Start-IcingaServiceCheckDaemon {}
```

Remove Daemons
---

Besides adding and displaying registered background daemons you can also use the unregister command to remove them

```powershell
Unregister-IcingaBackgroundDaemon -BackgroundDaemon 'Start-IcingaServiceCheckDaemon';
```

Once you restart the PowerShell service the pending changes are applied

```powershell
Restart-IcingaService 'icingapowershell';
```

Write Custom Daemons
---

In addition you are free to write your own extensions you can register within the framework. Every PowerShell daemon which is available within a single PowerShell session - even from different modules - can be used.

Best practice would be to create an own custom PowerShell Module which will create a new thread and executing certain tasks. Once this module is available in your PowerShell session, you can simply register and use it.

For a detailed guide you should check out the [daemon developer guide](../developerguide/10-Custom-Daemons.md).
