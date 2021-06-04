Icinga Integration
===

Once you followed the [Installation Guide](02-Installation.md) you are ready to start the integration into Icinga 2. This will allow you to configure your Check-Commands and start using them inside service templates and services.

Before you get started, be aware that you always have to use

```powershell
Use-Icinga
```

before you can execute framework related Cmdlets and functions. Otherwise you might run into errors.

Configuring Check-Commands
---

Before you can add Services to Hosts you need to define CheckCommands.  These definitions are not provided with Icinga for Windows, but there are two automatic ways to generate these check command objects, and you can also do it manually:

* [Automated Icinga Director configuration](icingaintegration/01-Director-Baskets.md) with Baskets
* [Automated Icinga 2 configuration](icingaintegration/04-Icinga-Config.md) with plain Icinga config
* [Manual configuration](icingaintegration/02-Manual-Integration.md) of check commands

Other Topics
---
* [Using PowerShell Arrays in Icinga](icingaintegration/03-PowerShell-Arrays.md)
* [Windows Terminal Integration](icingaintegration/50-Windows-Terminal.md)
