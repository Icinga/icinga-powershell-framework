Installing the Module
=====================================

Before you can use this module, you will require to install and configure it. Once done, you are ready to start.

Install the module
--------------

At first we need to obtain folders in which we can install the module. To get a list of available directories, you can use this command:S
```powershell
    echo $env:PSModulePath
```

***We do recommend to use the Program Files folder (in case it's present) to install the module into, which will make the installation as service easier***

To be able to use the module, you will require to have it named **exactly** as the .psm1 and .psd1 files inside the repository.

To validate if the module is installed properly, you can start a new PowerShell instance and type the following command

```powershell
    Get-Module -ListAvailable -Name icinga-module-windows
``` 

If you receive an output stating that the module is installed, you are fine to continue.

Configure the module
--------------

Once the module is installed, you will want to run the initial setup. Therefor you will simply have to type in the command

```powershell
    Start-Icinga-Setup
```

This will create the base configuration of the module including the setup of directories and required files within the **PowerShell Module Directory**.

Once completed successfully, you are ready to get started with using it. This will include

* Using it localy with scripts
* Integrate it with the Icinga 2 Agent
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

* [Install the module as Windows Service](10-InstallService.md)
* [Integration into Icinga Web 2](11-IcingaWeb2Integration.md)