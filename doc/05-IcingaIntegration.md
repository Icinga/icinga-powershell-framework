Icinga Integration
===

Once you followed the [Installation Guide](02-Installation.md) you are ready to start the integration into Icinga 2. This will allow you to configure your Check-Commands and start using configuring service-templates and services.

Before you are getting started, be aware that you will always have to use

```powershell
Use-Icinga
```

before you are executing framework related Cmdlets and functions. Otherwise you might run into errors.

Configuring Check-Commands
---

To get started, there are two ways for getting all Check-Commands configured.

* [Automated coniguration](icingaintegration/01-DirectorBaskets.md) with Baskets
* [Manual configuration](icingaintegration/02-Icinga2AgentExample.md) of Check-Commands
