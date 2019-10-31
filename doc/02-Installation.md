Installing the Module
===

Installing the module is managed by different ways, depending on the user environment including available possibitilies

Instructions
---

* Install the Module with the [Kickstart Script](installation/01-KickstartScript.md)
* Install the Module [manually](installation/02-ManualInstallation.md)

Testing the installation
---

Once the module is installed you can try if the installation was successfully by using the command

```powershell
Use-Icinga
```

This command will initialise the entire module and load all available Cmdlets.

Whenever you intend to use specific Cmdlets of the framework for Icinga Plugins, Testing or configuration you will require to run this command for each new PowerShell instance to initialise the framework.
