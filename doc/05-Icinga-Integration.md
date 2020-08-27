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

To get started, there are two ways to configure check command objects:

* [Automated configuration](icingaintegration/01-Director-Baskets.md) with Baskets
* [Manual configuration](icingaintegration/02-Manual-Integration.md) of check commands
* [Using PowerShell Arrays in Icinga](icingaintegration/03-PowerShell-Arrays.md)