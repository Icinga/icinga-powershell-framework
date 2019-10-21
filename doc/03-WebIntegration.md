Web Integration (Deprecated)
===

Before you can use this module, you will require to install and configure it. Once done, you are ready to start.

Configure the module
---

Once the module is installed, you will want to run the initial setup. Therefor you will simply have to type in the command

```powershell
Install-Icinga
```

This will create the base configuration of the module including the setup of directories and required files within the **PowerShell Module Directory**.

Once completed successfully, you are ready to get started with using it. This will include

* Using it localy with scripts
* Integration into for the Icinga 2 Agent
* Use it as Remote Execution target
* Integrate it into Icinga Web 2

If you wish to provide a Rest-Api of this module, you can run this Module as daemon. It will then listen on the default port **5891**

```powershell
Start-Icinga-Daemon
```

Of course if you wish to actively send data to Icinga Web 2 for example, you can do so by running the Checker component

```powershell
Start-Icinga-Checker
```

For additional setup possibilities, please take a look on the following pages:

* [Use the module as Icinga Plugin Framework](12-Icinga2AgentExample.md)
* [Install the module as Windows Service](10-InstallService.md)
* [Integration into Icinga Web 2](11-IcingaWeb2Integration.md)
