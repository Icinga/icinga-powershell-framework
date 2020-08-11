Installing the Icinga PowerShell Framework
===

Installing the Icinga PowerShell Framework is managed by different ways, depending on the user environment including available possibitilies

Instructions
---

* Install the Icinga PowerShell Framework with the [Kickstart Script](installation/01-Kickstart-Script.md)
* Install the Icinga PowerShell Framework [manually](installation/02-Manual-Installation.md)
* Install the Icinga PowerShell Framework with [PowerShell Gallery](installation/03-PowerShell-Gallery-Installation.md)

Testing the installation
---

Once the Icinga PowerShell Framework is installed you can try if the installation was successfully by using the command

```powershell
Use-Icinga
```

This command will initialise the entire Icinga PowerShell Framework and load all available Cmdlets.

*Note:* Starting with Icinga PowerShell Framework `1.2.0` you can simply use `icinga` to open a Icinga PowerShell Framework shell.

Whenever you intend to use specific Cmdlets of the framework for Icinga Plugins, Testing or configuration you will require to run this command for each new PowerShell instance to initialise the framework.

Icinga Agent installation wizard
---

Once the entire Framework is installed and the module is runnable, you can start the Icinga Agent installation wizard. Please follow the [Icinga Agent Wizard](installation/04-Icinga-Agent-Wizard.md) guide for examples and usage.

Service Installation
---

You can install a service which will allow you to run the PowerShell Framework as background daemon. This will add the possibility to register functions to run frequently for collecting data or execute different tasks on the system.

To install the service you can either follow the `IcingaAgentInstallWizard` or do it [manually](service/01-Install-Service.md)
